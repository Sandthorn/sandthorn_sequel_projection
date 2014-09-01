require 'forwardable'

module SandthornSequelProjection
  class ProcessedEventsTracker
    extend Forwardable

    def_delegator self, :table_name
    def_delegators :db_connection, :transaction

    attr_reader :db_connection, :identifier, :lock

    DEFAULT_TABLE_NAME = :processed_events_trackers

    def initialize(identifier, db_connection = nil)
      @identifier = identifier.to_s
      @db_connection = db_connection || SandthornSequelProjection.configuration.projections_driver
      @lock = Lock.new(identifier, @db_connection)
      ensure_row
    end

    def with_lock
      @lock.acquire do
        yield
      end
    end

    def process_events(&block)
      with_lock do
        cursor = Cursor.new(after_sequence_number: last_processed_sequence_number)
        events = cursor.get_batch
        transaction do
          until(events.empty?)
            block.call(events)
            events = cursor.get_batch
          end
          write_sequence_number(cursor.last_sequence_number)
        end
      end
    end

    def last_processed_sequence_number
      row[:last_processed_sequence_number]
    end

    def table
      db_connection[table_name]
    end

    def row_exists?
      !row.nil?
    end

    def row
      table.where(identifier: identifier).first
    end

    def reset
      with_lock do
        write_sequence_number(0)
      end
    end

    def self.table_name
      DEFAULT_TABLE_NAME
    end

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

  private

    def write_sequence_number(number)
      table.where(identifier: identifier).update(last_processed_sequence_number: number)
    end

    def ensure_row
      create_row unless row_exists?
    end

    def create_row
      table.insert(identifier: identifier)
    end

  end
end