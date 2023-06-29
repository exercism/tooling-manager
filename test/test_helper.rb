ENV["EXERCISM_ENV"] = "test"

# This must happen above the env require below
if ENV["CAPTURE_CODE_COVERAGE"]
  require 'simplecov'
  SimpleCov.start
end

gem "minitest"
require "minitest/autorun"
require "minitest/pride"
require "minitest/mock"
require "mocha/minitest"
require "timecop"

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require "tooling_manager"

module Minitest
  class Test
    def write_to_dynamodb(table_name, item)
      client = Exercism.dynamodb_client
      client.put_item(
        table_name:,
        item:
      )
    end
  end
end
