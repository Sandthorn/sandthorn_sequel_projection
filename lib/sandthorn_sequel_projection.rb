require 'sequel'
require "sandthorn_sequel_projection/version"
require "sandthorn_sequel_projection/projection"
require "sandthorn_sequel_projection/lock"

module SandthornSequelProjection

  class << self

    attr_accessor :configuration

    def configure
      @configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

  end

  class Configuration
  end
end
