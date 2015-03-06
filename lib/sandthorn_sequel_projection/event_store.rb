module SandthornSequelProjection
  class EventStore
    def initialize(name = :default)
      @name = name || :default
    end

    def get_events(*args)
      keywords = args.pop || {}
      keywords[:event_store] = @name
      puts keywords.inspect
      Sandthorn.get_events(after_sequence_number: 0)
    end
  end
end