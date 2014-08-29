require 'forwardable'
module SandthornSequelProjection
  class Lock
    extend Forwardable

    attr_reader :db_connection, :identifier

    def_delegators :db_connection, :transaction

    DEFAULT_TIMEOUT = 3*60 # 3 minutes
    DEFAULT_LOCK_COLUMN = :locked_at

    def initialize(identifier, db_connection = nil, table_name = nil)
      @identifier     = identifier.to_s
      @db_connection  = db_connection || SandthornDriverSequel.configuration.projections_driver
      @table_name     = table_name || ProcessedEventsTracker::DEFAULT_TABLE_NAME
    end

    def locked?
      !unlocked?
    end

    def unlocked?
      locked_at.nil?
    end

    def expired?
      locked_at && (Time.now - locked_at > timeout)
    end

    def timeout
      DEFAULT_TIMEOUT
    end

    def acquire
      if attempt_lock
        yield
        release
      end
    end

    def release
      set_lock(nil)
    end

    def attempt_lock
      transaction do
        if unlocked? || expired?
          lock
        end
      end
    end

    def lock_column_name
      DEFAULT_LOCK_COLUMN
    end

    def lock
      set_lock(Time.now)
    end

    def db_row
      table.where(identifier: @identifier)
    end

    def table
      db_connection[@table_name]
    end

    def set_lock(value)
      db_row.update(lock_column_name => value)
    end

    def locked_at
      if row = db_row.first
        row[lock_column_name]
      end
    end
  end
end