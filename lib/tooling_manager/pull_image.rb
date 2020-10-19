module ToolingManager
  class PullImage
    include Mandate

    IMG_CMD = "/opt/container_tools/img".freeze
    STATE_DIRECTORY = "/tmp/state-img".freeze

    initialize_with :repo, :tag

    def call
      return if Dir.exist?(release_directory)

      FileUtils.mkdir_p(release_directory)
      FileUtils.chmod(0o750, release_directory)

      # TODO: Set permissions here?

      Dir.chdir(release_directory) do
        `#{IMG_CMD} pull -state #{STATE_DIRECTORY} #{image}`
        `#{IMG_CMD} unpack -state #{STATE_DIRECTORY} #{image}`
        `chmod -R 550 rootfs`
        `mkdir rootfs/mnt/exercism-iteration`
        `chmod -R 770 rootfs/mnt/exercism-iteration`
      end
    end

    memoize
    def release_directory
      Paths.release_path(repo, tag)
    end

    memoize
    def image
      # TODO; Retrieve this base url from ExercismConfig
      "591712695352.dkr.ecr.eu-west-2.amazonaws.com/#{repo}:#{tag}"
    end
  end
end
