module SandthornSequelProjection
  class Cursor

    attr_reader :last_event, :batch_size

    def initialize(
        after_event: "0",
        event_store: SandthornSequelProjection.event_store,
        batch_size: SandthornSequelProjection.batch_size)
      @last_event = after_event
      @batch_size = batch_size
      @event_store = event_store
    end

    def get_batch
      events = get_events
      events.tap do |events|
        if last_event = events.last
          @last_event = last_event[:sequence_number].to_s || last_event[:event_id] #sequence_number is bias from sandthorn_driver_sequel
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
      @event_store.get_events(after_event: last_event, take: batch_size)
    end

  end
end