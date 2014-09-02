module SandthornSequelProjection
  class Runner

    DEFAULT_INTERVAL = 0.5

    attr_reader :manifest, :interval

    def initialize(manifest, interval = DEFAULT_INTERVAL)
      @manifest = manifest
      @interval = interval
    end

    def run(infinite = true)
      @projections = manifest.projections.map do |projection_class|
        projection_class.new(db_connection)
      end
      migrate!
      if infinite
        start_loop
      else
        loop_once
      end
    end

  private

    def start_loop
      while true
        loop_once
      end
    end

    def loop_once
      @projections.each do |projection|
        projection.update!
      end
      sleep(interval)
    end

    def db_connection
      SandthornSequelProjection.configuration.projections_driver
    end

    def migrate!
      @projections.each(&:migrate!)
    end

  end

  class CircularQueue < Queue

    # = CircularQueue
    # Automatically pushes popped elements to the back of the queue
    # In other words, can never be emptied by use of pop
    def pop
      super.tap do |el|
        self << el
      end
    end

  end
end