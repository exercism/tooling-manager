module ToolingManager
  class PromoteReleaseToCurrent
    include Mandate

    initialize_with :repo_name, :tag

    # TODO: Work out why this makes two versions of the link
    # and how to install a version with the `-h` flag
    # which should supposedly fix this.
    # https://stackoverflow.com/a/30470584/856688
    def call
      target = Paths.release_path(repo_name, tag)
      link = Paths.current_path(repo_name)

      `rm #{link}.new`
      `ln -s #{target} #{link}.new`
      `mv #{link}.new #{link}`
      FileUtils.chmod(0o750, link)
    end
  end
end
