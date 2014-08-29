require 'forwardable'

 module SandthornSequelProjection
  class Projection
    extend Forwardable

    def_delegator self, :identifier

    attr_reader :db_connection, :event_handlers

    def initialize(db_connection = nil)
      @db_connection = db_connection || SandthornSequelProjection.configuration.projections_driver
      @tracker = ProcessedEventsTracker.new(identifier, @db_connection)
      @event_handlers = self.class.event_handlers
    end

    def migrate!
      (self.class.migration || Utilities::NullProc.new).call(db_connection)
    end

    def update!
      tracker.with_lock do
        events = tracker.unprocessed_events
        handlers.handle(events)
        update_last_processed
      end
    end

    class << self

      attr_accessor :migration, :event_handlers

      def define_migration(migration = nil)
        self.migration = migration || Proc.new # Proc.new will wrap the block argument in a Proc
      end

      def define_event_handlers
        @event_handlers ||= EventHandlerCollection.new
        yield(@event_handlers)
      end

      def identifier
        self.name.gsub(/::/, '_').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
      end
    end

  end
end