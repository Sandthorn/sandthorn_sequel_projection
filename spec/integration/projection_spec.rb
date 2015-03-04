require 'spec_helper'

module SandthornSequelProjection

  class MyProjection < Projection

    migration("20150303-1") do |db_con|
      db_con.create_table?(table_name) do
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
      aggregate_id = event[:aggregate_id]
      add_aggregate(aggregate_id)
    end

    def add_aggregate(aggregate_id)
      db_connection.transaction do
        exists = table.where(aggregate_id: aggregate_id).any?
        unless exists
          table.insert(aggregate_id: aggregate_id)
        end
      end
    end

    def product_added(event)
      if on_sale?(event)
        add_aggregate(event[:aggregate_id])
      end
    end

    def removed_from_sale(event)
      aggregate_id = event[:aggregate_id]
      table.where(aggregate_id: aggregate_id).delete
    end

    def on_sale?(event)
      event[:on_sale]
    end

    def table
      db_connection[table_name]
    end

    def table_name
      :products_on_sale
    end

    def aggregates_on_sale_ids
      table.select_map(:aggregate_id)
    end
  end

  describe MyProjection do

    def db_connection
      SandthornSequelProjection.configuration.projections_driver
    end

    def table
      db_connection[projection.table_name]
    end

    let(:projection) { MyProjection.new }

    before do
      Sandthorn.default_event_store = MockEventStore.with_data
    end

    describe "#migrate!" do
      it "creates the wanted table" do
        projection.migrate!
        expect(table.all).to eq([])
      end
    end

    describe "#update" do
      before do
        projection.migrate!
      end
      methods = [:product_added, :removed_from_sale]
      methods.each do |method|
        it "calls #{method}" do
          expect(projection).to receive(method).at_least(:once).and_call_original
          projection.update!
        end
      end

      it "sets the correct last_processed_sequence_number" do
        expected = %w[
          ac1be457-b6b9-4dad-900b-acb400f810df
        ]
        projection.update!
        expect(projection.aggregates_on_sale_ids).to eq(expected)
      end

      it "sets the correct last updated at" do
        projection.update!
        expect(projection.last_processed_sequence_number).to eq(128)
      end
    end
  end
end