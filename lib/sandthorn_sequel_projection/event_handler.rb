module SandthornSequelProjection
  class EventHandler

    attr_reader :projection, :filter, :method

    def initialize(projection, options)
      @projection = projection
      @filter = SandthornEventFilter::Filter.new
      parse_options(options)
    end

    def handle(event)
      if filter.match?(event)
        call_handler(event)
      end
    end

  private

    def parse_options(options)
      if options.is_a? Symbol
        set_method(options)
      elsif options.is_a? Hash
        method_name = options.keys.first
        set_method(method_name)
        construct_filter(options[method_name])
      end
    end

    def call_handler(event)
      @method.call(event)
    end

    def construct_filter(options)
      types, event_names = extract_filter_options(options)
      @filter = @filter.extract(types: types) if types.any?
      @filter = @filter.extract(events: event_names) if types.any?
    end

    def extract_filter_options(options)
      types   = Array.wrap(options[:aggregate_type] || options[:aggregate_types])
      events  = Array.wrap(options[:event_name] || options[:event_names])
      [types, events]
    end

    def set_method(handle)
      @method = @projection.method(handle)
    end
  end
end