module SandthornSequelProjection
  class Manifest

    attr_reader :projections

    def initialize(*projections)
      @projections = Array.wrap(projections).flatten
    end
  end
end