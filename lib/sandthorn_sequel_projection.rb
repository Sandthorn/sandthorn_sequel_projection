require "sequel"
require "sandthorn_event_filter"

module SandthornSequelProjection

  class << self

    attr_accessor :configuration

    def configure
      @configuration ||= Configuration.default
      yield(configuration) if block_given?
    end

    def start
      ProcessedEventsTracker.migrate!(configuration.projections_driver)
    end

    def event_store
      configuration.event_store
    end

    def batch_size
      configuration.batch_size
    end

  end

  class Configuration

    attr_accessor :projections_driver, :event_store, :projections_folder, :batch_size

    def initialize
      yield(self) if block_given?
    end

    def self.default
      self.new do |c|
        c.batch_size = 40
      end
    end

  end
end

require "sandthorn_sequel_projection/version"
require "sandthorn_sequel_projection/utilities"
require "sandthorn_sequel_projection/cursor"
require "sandthorn_sequel_projection/event_handler"
require "sandthorn_sequel_projection/event_handler_collection"
require "sandthorn_sequel_projection/projection"
require "sandthorn_sequel_projection/lock"
require "sandthorn_sequel_projection/processed_events_tracker"
require "sandthorn_sequel_projection/manifest"
require "sandthorn_sequel_projection/runner"