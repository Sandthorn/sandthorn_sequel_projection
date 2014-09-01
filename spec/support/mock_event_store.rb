module SandthornSequelProjection
  class MockEventStore

    def initialize(events = nil)
      @events = Array.wrap(events)
    end

    def reset
      @events = []
    end

    def add_event(event)
      @events << event
    end

    alias_method :add, :add_event

    def get_events(after_sequence_number: 0, take: 1)
      start = after_sequence_number
      stop = after_sequence_number + take - 1
      Array.wrap(@events[start..stop])
    end

  end

end
