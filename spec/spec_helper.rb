if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

require 'sandthorn_sequel_projection'
require 'sandthorn_event_filter/rspec/custom_matchers'

RSpec.configure do |config|
end

SandthornSequelProjection.configure do |config|
  config.projections_driver = Sequel.sqlite
end

SandthornSequelProjection.start