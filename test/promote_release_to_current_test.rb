require 'test_helper'

module ToolingManager
  class PromoteReleaseToCurrentTest < Minitest::Test
    def test_sets_a_symlink
      s = PromoteReleaseToCurrent.new("csharp-representer", "foobar123")
      s.expects(:system).with("ln -fs /opt/containers/csharp-representer/releases/foobar123 /opt/containers/csharp-representer/current") # rubocop:disable Layout/LineLength
      s.()
    end
  end
end
