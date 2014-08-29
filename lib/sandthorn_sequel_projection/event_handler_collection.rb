require "forwardable"

module SandthornSequelProjection
  class EventHandlerCollection
    extend Forwardable
    def_delegators :handlers, :length

    attr_reader :handlers

    def initialize
      @handlers = Set.new
    end

    def add(handler)
      @handlers << handler
    end

    def handle(events)
      events.each do |event|
        handlers.each do |handler|
          handler.handle(events)
        end
      end
    end

  end
end