source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'mandate'
gem "aws-sdk-ecr"
gem 'zeitwerk'
gem "rake"
gem 'exercism-config', '>= 0.45.0'

gem "mocha"
gem "minitest"
gem "timecop"
gem 'rubocop'
gem 'rubocop-minitest'
gem 'rubocop-performance'
gem 'simplecov', '~> 0.17.0'

