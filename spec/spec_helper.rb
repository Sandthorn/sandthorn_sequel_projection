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
  config.before(:each) do
    SandthornSequelProjection.configure do |config|
      config.db_connection = Sequel.sqlite
    end
  end
end

Sandthorn.configure do |sand|
  sand.event_stores = { default: SandthornSequelProjection::MockEventStore.new }
end