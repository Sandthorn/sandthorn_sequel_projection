module SandthornSequelProjection
  class ProcessedEventsTracker

    DEFAULT_TABLE_NAME = :processed_events_trackers

    def initialize(db_connection, identifier)
      @db = db_connection
      @lock = Lock.new(db_connection, identifier)
    end

    def with_lock
      @lock.acquire do
        yield
      end
    end

    def unprocessed_events
      Sandthorn.get_events(after_sequence_number: last_processed_sequence_number)
    end

    def last_processed_sequence_number

    end

  end
end