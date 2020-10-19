module ToolingManager
  class Manage
    include Mandate

    def call
      tags = ExtractMachineTags.()
      repos = DetermineToolingRepos.(tags)

      repos.each do |repo_name|
        production_tag = RetrieveProductionRepoTag.(repo_name)

        # If repo_tag is missing, unset the production symlink
        # if it exists, and then continue onto the next repo
        unless production_tag
          FileUtils.rm_r(Paths.current_path(repo_name))
          next
        end

        log_in_to_ecr!

        # Pull and unpack the image. This is a noop if the
        # repo directory already exists
        PullImage.(repo_name, production_tag)

        # Create a symlink to the new production tag
        PromoteReleaseToCurrent.(repo_name, production_tag)
      end
    end

    private
    # Just do this once per run of this command
    def log_in_to_ecr!
      return if @logged_in_to_ecr

      `aws ecr get-login-password --region eu-west-2 | /opt/container_tools/img login -u AWS --password-stdin 591712695352.dkr.ecr.eu-west-2.amazonaws.com` # rubocop:disable Layout/LineLength
      @logged_in_to_ecr = true
    end
  end
end
