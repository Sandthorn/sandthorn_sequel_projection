module SandthornSequelProjection
  class EventStore
    def initialize(name = :default)
      @name = name || :default
    end

    def get_events(*args)
      keywords = args.pop || {}
      keywords[:event_store] = @name
      Sandthorn.get_events(keywords)
    end
  end
end