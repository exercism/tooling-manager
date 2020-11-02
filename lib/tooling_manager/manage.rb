module ToolingManager
  class Manage
    include Mandate

    def call
      tags = ExtractMachineTags.()
      repos = DetermineToolingRepos.(tags)

      # Just do this once per run of this command
      log_in_to_ecr!

      repos.each do |repo_name|
        puts "** Installing #{repo_name}:production"
        system("docker pull #{Exercism.config.tooling_ecr_repository_url}/#{repo_name}:production")
      end
    end

    private
    def log_in_to_ecr!
      puts "** Logging into ECR"

      # TODO; Retrieve this region from ExercismConfig
      system("aws ecr get-login-password --region eu-west-2 | docker login -u AWS --password-stdin #{Exercism.config.tooling_ecr_repository_url}") # rubocop:disable Layout/LineLength
    end
  end
end
