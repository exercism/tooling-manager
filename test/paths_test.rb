require 'test_helper'

module ToolingManager
  class PathsTest < Minitest::Test
    def test_release_path
      expected = "/opt/containers/ruby-test-runner/releases/foobar"
      actual = Paths.release_path('ruby-test-runner', 'foobar')
      assert_equal expected, actual
    end

    def test_current_path
      expected = "/opt/containers/javascript-analyzer/current"
      actual = Paths.current_path('javascript-analyzer')
      assert_equal expected, actual
    end
  end
end
