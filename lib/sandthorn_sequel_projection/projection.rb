module SandthornSequelProjection
  class Projection

    def update!
      raise NotImplementedError, "Subclasses of Projection must implement `update!`"
    end

    class << self

      attr_accessor :migration

      def define_migration(migration = nil)
        self.migration = migration || Proc.new
      end

      def migrate!(connection)
        (self.migration || Proc.new {}).call(connection)
      end

    end

  end
end