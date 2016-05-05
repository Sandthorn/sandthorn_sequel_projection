require 'json'
require 'pp'
module SandthornSequelProjection
  class MockSequelEventStore

    def initialize(events = nil)
      Array.wrap(events).each do |event|
        add_event(event)
      end
    end

    def reset(events = [])
      @events = events
    end

    def events
      @events ||= []
    end

    def add_event(event)
      events << event
    end

    alias_method :add, :add_event

    def get_events(after_event: "0", take: 1, **rest)
      unless numeric?(after_event.to_i, take)
        raise ArgumentError, "arguments have to be numbers, received: #{after_event.inspect} and #{take.inspect}"
      end
      events.select { |event| event[:sequence_number].to_i > after_event.to_i }.take(take).map { |e| e.dup }
    end

    def numeric?(*args)
      args.all? { |arg| arg.is_a?(Numeric) }
    end

    def self.with_data
      self.new(JSON.parse(File.read("./spec/test_data/sequel_event_data.json"), symbolize_names: true))
    end

  end

end
