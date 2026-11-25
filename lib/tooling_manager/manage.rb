module ToolingManager
  class Manage
    include Mandate

    def call
      # Do this at the beginning in case a previous run has left things dirty
      # which could cause the code below to blow up.
      prune_all!

      tags = ExtractMachineTags.()
      repos = DetermineToolingRepos.(tags)

      # Just do this once per run of this command
      log_in_to_ecr!

      repos.each do |repo_name|
        puts "** Installing #{repo_name}:production"
        system("docker pull #{image_for(repo_name)}:production")

        # Remove this repo's old copy straight away rather than waiting for
        # the end of the pass. When the tag moves, the previous image is left
        # untagged but still on disk, so a pass where many images have
        # changed (e.g. the first boot of an AMI that is a few months old)
        # would otherwise hold two copies of each until the pass finished -
        # enough to fill the disk.
        remove_untagged!(repo_name)
      end
    end

    private
    def prune_all!
      system("docker image prune -f")
    end

    # Only untagged images belonging to this repo. If a job is still running
    # on the old image, rmi refuses and the copy is caught by the next pass.
    def remove_untagged!(repo_name)
      system("docker images --filter=reference='#{image_for(repo_name)}' --filter=dangling=true -q | xargs -r docker rmi") # rubocop:disable Layout/LineLength
    end

    def image_for(repo_name)
      "#{Exercism.config.tooling_ecr_repository_url}/#{repo_name}"
    end

    def log_in_to_ecr!
      puts "** Logging into ECR"

      # TODO; Retrieve this region from ExercismConfig
      system("aws ecr get-login-password --region eu-west-2 | docker login -u AWS --password-stdin #{Exercism.config.tooling_ecr_repository_url}") # rubocop:disable Layout/LineLength
    end
  end
end
