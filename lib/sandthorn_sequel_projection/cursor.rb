module SandthornSequelProjection
  class Cursor

    DEFAULT_BATCH_SIZE = 10

    attr_reader :last_sequence_number, :batch_size

    def initialize(
        after_sequence_number: 0,
        event_store: SandthornSequelProjection.event_store,
        batch_size: DEFAULT_BATCH_SIZE)
      @last_sequence_number = after_sequence_number
      @batch_size = batch_size
      @event_store = event_store
    end

    def get_batch
      events = @event_store.get_events(after_sequence_number: last_sequence_number, take: batch_size)
      events.tap do |events|
        if last_event = events.last
          @last_sequence_number = last_event[:sequence_number]
        end
      end
    end

  end
end