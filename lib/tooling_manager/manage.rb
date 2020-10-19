module ToolingManager
  class Manage
    include Mandate

    def call
      tags = ExtractMachineTags.()
      repos = DetermineToolingRepos.(tags)

      repos.each do |repo_name|
        puts "** Looking up production tag for #{repo_name}"
        production_tag = RetrieveProductionRepoTag.(repo_name)

        # If repo_tag is missing, unset the production symlink
        # if it exists, and then continue onto the next repo
        if production_tag
          puts "** Found production tag: #{repo_name}/#{production_tag}"
        else
          puts "** No production tag found"
          FileUtils.rm_r(Paths.current_path(repo_name))
          next
        end

        log_in_to_ecr!

        # Pull and unpack the image. This is a noop if the
        # repo directory already exists
        puts "** Installing #{repo_name}/#{production_tag}"
        PullImage.(repo_name, production_tag)

        # Create a symlink to the new production tag
        puts "** Promoting #{repo_name}/#{production_tag}"
        PromoteReleaseToCurrent.(repo_name, production_tag)
      end
    end

    private
    # Just do this once per run of this command
    def log_in_to_ecr!
      return if @logged_in_to_ecr

      puts "** Logging into ECR"

      # TODO; Retrieve this base url from ExercismConfig
      # TODO; Retrieve this region from ExercismConfig
      `aws ecr get-login-password --region eu-west-2 | /opt/container_tools/img login -u AWS --password-stdin 591712695352.dkr.ecr.eu-west-2.amazonaws.com` # rubocop:disable Layout/LineLength
      @logged_in_to_ecr = true
    end
  end
end
