require 'json'
require 'open3'
require 'fileutils'
require 'tmpdir'

module ToolingManager
  # Runs every test runner once, on its track's example solution, before the
  # invoker starts taking jobs.
  #
  # A new machine's root disk is restored from the AMI's snapshot. The first
  # time anything reads a block that came from the snapshot, EBS fetches it
  # from S3, which is very slow. Part of every pulled image lands on those
  # blocks, so each test runner's first one or two runs on a new machine are
  # slow enough to time out for students. Once a runner has run once, its
  # files are local and the machine stays fast for it. This pass pays that
  # cost before students do.
  #
  # The warm-up must never stop a machine from becoming ready, so every
  # problem is logged and skipped.
  class WarmUpTestRunners
    include Mandate

    initialize_with :repos

    # A first run can be very slow, so give each one far longer than the
    # invoker would. The whole pass gives up after MAX_TOTAL_SECONDS so that
    # a broken machine still becomes ready.
    RUN_TIMEOUT_SECONDS = 120
    MAX_TOTAL_SECONDS = 20 * 60

    JOBS_DIR = "/opt/jobs".freeze
    TOOLS_CONFIG_PATH = "/opt/tooling-invoker/tools.json".freeze

    # The website leaves these out of the files it sends with each job.
    UNSENT_DIRS = %w[.docs .approaches .articles].freeze

    def call
      started_at = now
      log "Warming up #{test_runners.size} test runners"

      # Elixir and Gleam run on this network. The invoker creates it too,
      # but only once it starts, which is after this.
      system("docker network create --internal internal", out: File::NULL, err: File::NULL)

      test_runners.each do |repo_name|
        if now - started_at > MAX_TOTAL_SECONDS
          log "Out of time, so skipping the remaining test runners"
          break
        end

        warm_up!(repo_name)
      end

      log "Warm-up finished in #{(now - started_at).round(1)}s"
    rescue StandardError => e
      log "Warm-up failed, so skipping it: #{e.message}"
    end

    private
    def test_runners = repos.select { |repo_name| repo_name.end_with?("-test-runner") }

    def warm_up!(repo_name)
      track = repo_name.delete_suffix("-test-runner")

      Dir.mktmpdir("warm-up-#{track}-", JOBS_DIR) do |dir|
        exercise = write_example_solution!(track, dir)
        unless exercise
          log "#{repo_name}: skipped, as there's no example solution for it"
          next
        end

        # The runner's user inside the container needs to write its results.
        FileUtils.chmod_R(0o777, dir)

        started_at = now
        _, status = Open3.capture2e(docker_run_command(repo_name, exercise, dir))
        log "#{repo_name}: ran #{exercise} in #{(now - started_at).round(1)}s (exit status #{status.exitstatus})"
      end
    rescue StandardError => e
      log "#{repo_name}: skipped after an error: #{e.message}"
    end

    # Copies an exercise from the track's repo on EFS into dir, as the website
    # would send it, with the exercise's example solution as the student's
    # files. Returns the exercise's slug, or nil if there isn't one to use.
    def write_example_solution!(track, dir)
      repo = "#{Exercism.config.efs_repositories_mount_point}/#{track}"
      return unless Dir.exist?(repo)

      exercise = choose_exercise(repo)
      return unless exercise

      path = "exercises/practice/#{exercise}"
      return unless system("git -C #{repo} archive HEAD #{path} | tar -x -C #{dir} --strip-components=3")

      UNSENT_DIRS.each { |unsent| FileUtils.rm_rf(File.join(dir, unsent)) }

      files = JSON.parse(File.read(File.join(dir, ".meta/config.json")))["files"]
      ExampleSolutionFiles.(files["solution"], files["example"]).each do |solution, example|
        FileUtils.mkdir_p(File.dirname(File.join(dir, solution)))
        FileUtils.cp(File.join(dir, example), File.join(dir, solution))
      end

      exercise
    end

    # Every track has hello-world, apart from a few. Those use their first
    # practice exercise instead.
    def choose_exercise(repo)
      paths = `git -C #{repo} ls-tree --name-only HEAD exercises/practice/`.split("\n")
      exercises = paths.map { |path| File.basename(path) }
      exercises.include?("hello-world") ? "hello-world" : exercises.min
    end

    # These match the flags in tooling-invoker's ExecDocker.
    def docker_run_command(repo_name, exercise, dir)
      tool = tools_config.fetch(repo_name.tr('-', '_'), {})
      [
        "/usr/bin/timeout -s SIGTERM -k 1 #{RUN_TIMEOUT_SECONDS}",
        "docker container run",
        "--stop-timeout 0",
        "--rm",
        "-v #{dir}:/mnt/exercism-iteration",
        "--network #{tool.fetch('network', 'none')}",
        "-m #{tool.fetch('max_memory', '3GB')}",
        "#{Exercism.config.tooling_ecr_repository_url}/#{repo_name}:production",
        exercise, "/mnt/exercism-iteration/", "/mnt/exercism-iteration/"
      ].join(" ")
    end

    # The invoker keeps each tool's network and memory limits in tools.json.
    memoize
    def tools_config
      JSON.parse(File.read(TOOLS_CONFIG_PATH))
    rescue StandardError
      {}
    end

    def now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    def log(message)
      puts "** Warm-up: #{message}"
      $stdout.flush
    end
  end
end
