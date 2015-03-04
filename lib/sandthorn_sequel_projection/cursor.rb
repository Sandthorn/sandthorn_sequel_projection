module SandthornSequelProjection
  class Cursor

    attr_reader :last_sequence_number, :batch_size

    def initialize(
        after_sequence_number: 0,
        event_store: SandthornSequelProjection.default_event_store,
        batch_size: SandthornSequelProjection.batch_size)
      @last_sequence_number = after_sequence_number
      @batch_size = batch_size
      @event_store = event_store
    end

    def get_batch
      events = get_events
      events.tap do |events|
        if last_event = events.last
          @last_sequence_number = last_event[:sequence_number]
        end
      end
    end

  private
    
    def get_events
      wrap(get_event_array)
    end

    def wrap(events)
      SandthornEventFilter.filter(events)
    end

    def get_event_array
      @event_store.get_events(after_sequence_number: last_sequence_number, take: batch_size)
    end

  end
end