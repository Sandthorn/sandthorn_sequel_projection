require 'spec_helper'

module SandthornSequelProjection

  class TestProjection < Projection

    define_migration do |db_con|
      db_con.create_table?(:products_on_sale) do
        primary_key :id
        String :aggregate_id
      end
    end

    define_event_handlers do |handlers|
      handlers.define product_added: {
          aggregate_type: "SandthornProduct",
          event_name: "new"
      }
      handlers.define on_sale: {
          aggregate_type: "SandthornProduct",
          event_name: "product_on_sale"
      }
      handlers.define removed_from_sale: {
          aggregate_type: "SandthornProduct",
          event_names: ["removed_from_sale", "destroyed"]
      }
    end

    def on_sale(event)
    end

    def product_added(event)
    end

    def removed_from_sale(event)
    end

  end

end