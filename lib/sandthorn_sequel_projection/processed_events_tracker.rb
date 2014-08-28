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
    def self.migrate!(db_connection)
      db_connection.create_table?(table_name) do
        String    :identifier
        Integer   :last_processed_sequence_number, default: 0
        DateTime  :locked_at, null: true
      end
      db_connection.add_index table_name, :identifier, unique: true
    rescue
      puts "Wowza, shit went down"
    end

    end

  end
end