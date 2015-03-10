require 'spec_helper'

module SandthornSequelProjection

  class MyProjection < Projection

    migration("20150303-1") do |db_con|
      db_con.create_table?(table_name) do
        primary_key :id
        String :aggregate_id
        TrueClass :on_sale, default: false
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
      aggregate_id = event[:aggregate_id]
      add_aggregate(aggregate_id)
      table.where(aggregate_id: aggregate_id).update(on_sale: true)
    end

    def add_aggregate(aggregate_id)
      db_connection.transaction do
        exists = table.where(aggregate_id: aggregate_id).any?
        return exists || table.insert(aggregate_id: aggregate_id)
      end
    end

    def product_added(event)
      add_aggregate(event[:aggregate_id])
    end

    def removed_from_sale(event)
      aggregate_id = event[:aggregate_id]
      table.where(aggregate_id: aggregate_id).update(on_sale: false)
    end

    def table
      db_connection[table_name]
    end

    def table_name
      :products_on_sale
    end

    def aggregates_on_sale_ids
      table.where(on_sale: true).select_map(:aggregate_id)
    end

    def aggregate_ids
      table.select_map(:aggregate_id)
    end
  end
end