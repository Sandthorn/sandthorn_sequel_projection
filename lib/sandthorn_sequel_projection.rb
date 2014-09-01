require 'sequel'
require 'sandthorn_event_filter'
require "sandthorn_sequel_projection/version"
require "sandthorn_sequel_projection/utilities"
require "sandthorn_sequel_projection/cursor"
require "sandthorn_sequel_projection/event_handler"
require "sandthorn_sequel_projection/event_handler_collection"
require "sandthorn_sequel_projection/projection"
require "sandthorn_sequel_projection/lock"
require "sandthorn_sequel_projection/processed_events_tracker"

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

  end

  class Configuration
    attr_accessor :projections_driver, :event_store, :projections_folder
    class << self
      alias_method :default, :new
    end
  end
end

