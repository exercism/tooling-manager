require 'test_helper'

module ToolingManager
  class DetermineToolingReposTest < Minitest::Test
    def setup
      write_to_dynamodb(
        Exercism.config.dynamodb_tooling_language_groups_table,
        {
          "group" => "test-runners-web",
          "languages" => "ruby,javascript,elixir"
        }
      )

      write_to_dynamodb(
        Exercism.config.dynamodb_tooling_language_groups_table,
        {
          "group" => "test-runners-interpolated",
          "languages" => "ruby,javascript"
        }
      )

      write_to_dynamodb(
        Exercism.config.dynamodb_tooling_language_groups_table,
        {
          "group" => "analyzers-all",
          "languages" => "ruby,elixir"
        }
      )

      write_to_dynamodb(
        Exercism.config.dynamodb_tooling_language_groups_table,
        {
          "group" => "representers-interpolated",
          "languages" => "ruby,javascript"
        }
      )

      write_to_dynamodb(
        Exercism.config.dynamodb_tooling_language_groups_table,
        {
          "group" => "representers-compiled",
          "languages" => "erlang,csharp"
        }
      )
    end

    def test_determines_things_correctly
      tags = {
        "tooling-test-runners" => "web,interpolated",
        "tooling-analyzers" => "all",
        "tooling-representers" => "compiled"
      }
      expected = %w[
        ruby-test-runner
        javascript-test-runner
        elixir-test-runner
        ruby-analyzer
        elixir-analyzer
        erlang-representer
        csharp-representer
      ]
      assert_equal expected, DetermineToolingRepos.(tags)
    end

    def test_copes_with_missing_groups
      tags = {
        "tooling-test-runners" => "interpolated"
      }
      expected = %w[
        ruby-test-runner
        javascript-test-runner
      ]
      assert_equal expected, DetermineToolingRepos.(tags)
    end

    def test_copes_with_empty_groups
      tags = {
        "tooling-test-runners" => "interpolated",
        "tooling-analyzers" => "",
        "tooling-representers" => ""
      }
      expected = %w[
        ruby-test-runner
        javascript-test-runner
      ]
      assert_equal expected, DetermineToolingRepos.(tags)
    end
  end
end
