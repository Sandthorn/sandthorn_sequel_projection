module SandthornSequelProjection
  module Utilities
    class NullProc < Proc
      def self.new
        super() {}
      end
    end
  end
end