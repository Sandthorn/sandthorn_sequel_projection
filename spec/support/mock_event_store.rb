require 'json'
require 'pp'
module SandthornSequelProjection
  class MockEventStore

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

    def get_events(after_sequence_number: 0, take: 1, **rest)
      unless numeric?(after_sequence_number, take)
        raise ArgumentError, "arguments have to be numbers, received: #{after_sequence_number.inspect} and #{take.inspect}"
      end
      events.select { |event| event[:sequence_number] > after_sequence_number }.take(take).map { |e| e.dup }
    end

    def numeric?(*args)
      args.all? { |arg| arg.is_a?(Numeric) }
    end

    def self.with_data
      self.new(JSON.parse(File.read("./spec/test_data/event_data.json"), symbolize_names: true))
    end

  end

end
