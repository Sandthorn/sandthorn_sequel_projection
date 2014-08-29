require 'sequel'
require 'sandthorn_event_filter'
require "sandthorn_sequel_projection/version"
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

  end

  class Configuration
    attr_accessor :projections_driver, :event_driver, :projections_folder
    class << self
      alias_method :default, :new
    end
  end
end
