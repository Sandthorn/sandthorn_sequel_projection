if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

require 'sandthorn_sequel_projection'
require 'sandthorn_event_filter/rspec/custom_matchers'
require 'support/mock_event_store'

RSpec.configure do |config|
end

SandthornSequelProjection.configure do |config|
  config.projections_driver = Sequel.sqlite
  config.event_store = SandthornSequelProjection::MockEventStore.new
end

SandthornSequelProjection.start