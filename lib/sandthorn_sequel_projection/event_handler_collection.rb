require "forwardable"

module SandthornSequelProjection
  class EventHandlerCollection
    extend Forwardable
    def_delegators :handlers, :length, :each, :first

    attr_reader :handlers

    def initialize
      @handlers = Set.new
    end

    def define(handler_data)
      @handlers << EventHandler.new(handler_data)
    end

    def handle(projection, events)
      events.each do |event|
        handlers.each do |handler|
          handler.handle(projection, event)
        end
      end
    end

  end
end