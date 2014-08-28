require 'sequel'
require "sandthorn_sequel_projection/version"
require "sandthorn_sequel_projection/event_handlers"
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

  end

  class Configuration
    attr_accessor :projections_driver, :event_driver, :projections_folder
  end
end
