if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

require 'sandthorn_driver_sequel'
require 'sandthorn_sequel_projection'
require 'sandthorn_event_filter/rspec/custom_matchers'
require 'support/mock_event_store'

RSpec.configure do |config|
  config.before(:each) do

    #default use inmemory projection
    SandthornSequelProjection.configure do |config|
      config.db_connection = Sequel.sqlite
    end

    #deafault use mocked event store
    Sandthorn.configure do |sand|
      sand.event_stores = { default: SandthornSequelProjection::MockEventStore.new }
    end
  end

end



def projection_db_path 
  "sqlite://spec/db/projection.sqlite3" 
end

def event_store_db_path
  "sqlite://spec/db/event_store.sqlite3"
end


def setup_db_event_store
  db = SandthornDriverSequel.driver_from_url(url: event_store_db_path)
  migrator = SandthornDriverSequel::Migration.new url: event_store_db_path
  SandthornDriverSequel.migrate_db url: event_store_db_path
  migrator.send(:clear_for_test)
  
  Sandthorn.configure do |sand|
    sand.event_stores = { default: db }
  end
end

def clear_event_store
  migrator = SandthornDriverSequel::Migration.new url: event_store_db_path
  migrator.send(:clear_for_test)
end

def setup_db_projection
  db = Sequel.connect projection_db_path

  SandthornSequelProjection.configure do |config|
    config.db_connection = db
  end
end

def clear_db_projections table_names
  db = Sequel.connect projection_db_path
  table_names = [table_names] unless table_names.is_a? Array
  
  table_names.each { |e| db.drop_table? e }
  db.drop_table? :schema_migrations
  db.drop_table? :processed_events_trackers
end