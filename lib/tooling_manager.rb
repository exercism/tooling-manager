ENV["EXERCISM_ENV"] ||= "development"

require 'mandate'
require 'aws-sdk-ecr'
require 'exercism-config'

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module ToolingManager
end
