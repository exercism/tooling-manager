module ToolingManager
  class Paths
    CONTAINERS_PATH = "/opt/containers".freeze

    def self.release_path(repo_name, tag)
      "#{CONTAINERS_PATH}/#{repo_name}/releases/#{tag}"
    end

    def self.current_path(repo_name)
      "#{CONTAINERS_PATH}/#{repo_name}/current"
    end
  end
end
