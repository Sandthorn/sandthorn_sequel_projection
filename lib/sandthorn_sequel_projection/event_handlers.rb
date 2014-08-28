module SandthornSequelProjection
  class EventHandlers

    def initializer
      @handlers = Set.new
    end

    def add(handler)
      @handlers << handler
    end

  end
end