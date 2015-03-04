require 'forwardable'

 module SandthornSequelProjection
  class Projection
    extend Forwardable
    include SimpleMigrator::Migratable

    def_delegators self, :identifier, :event_store
    def_delegators :tracker, :last_processed_sequence_number

    attr_reader :db_connection, :event_handlers, :tracker

    def initialize(db_connection = nil)
      @db_connection = db_connection || SandthornSequelProjection.configuration.projections_driver
      @tracker = ProcessedEventsTracker.new(
          identifier: identifier,
          db_connection: @db_connection,
          event_store: event_store)
      @event_handlers = self.class.event_handlers
    end

    def update!
      tracker.process_events do |batch|
        event_handlers.handle(self, batch)
      end
    end

    def migrator
      SimpleMigrator.migrator(db_connection)
    end

    class << self
      attr_reader :event_store_name

      def event_store(event_store = nil)
        if event_store
          @event_store_name = event_store
        else
          find_event_store
        end
      end

      def find_event_store
        SandthornSequelProjection.find_event_store(@event_store_name)
      end

      attr_reader :event_store_name
      attr_accessor :event_handlers

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