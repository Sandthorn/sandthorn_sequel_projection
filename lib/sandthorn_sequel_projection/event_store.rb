module SandthornSequelProjection
  class EventStore
    def initialize(name = :default)
      @name = name || :default
    end

    def get_events(*args)
      keywords = args.pop || {}
      SandthornSequelProjection.configuration.event_stores[@name].get_events(keywords)
    end
  end
end