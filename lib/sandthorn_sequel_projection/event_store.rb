require 'delegate'

module SandthornSequelProjection
  class EventStore < SimpleDelegator

    def initialize(store = default_store)
      super(store)
      check_store!
    end

    def default_store
      if defined?(::Sandthorn)
        ::Sandthorn
      end
    end

  private

    def check_store!
      unless self.respond_to?(:get_events)
        raise SandthornSequelProjection::InvalidEventStoreError, "Event store #{inspect} doesn't have a #get_events method"
      end
    end

  end
end