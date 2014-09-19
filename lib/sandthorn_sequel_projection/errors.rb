module SandthornSequelProjection

  class SandthornSequelProjectionError < StandardError; end

  class MigrationError < SandthornSequelProjectionError
    def initialize(error)
      super(error.message)
      @error = error
    end
  end

  class InvalidEventStoreError < SandthornSequelProjectionError; end

end