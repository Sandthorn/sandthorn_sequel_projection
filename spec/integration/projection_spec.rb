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

  describe MyProjection do

    def db_connection
      SandthornSequelProjection.configuration.db_connection
    end

    def table
      db_connection[projection.table_name]
    end

    let(:projection) { MyProjection.new }

    before do
      SandthornSequelProjection.configuration.event_stores = { default: MockEventStore.with_data }
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

      describe "data" do
        before { projection.update! }
        it "sets the on_sale boolean correctly" do
          expected = %w[
          ac1be457-b6b9-4dad-900b-acb400f810df
        ]
          expect(projection.aggregates_on_sale_ids).to eq(expected)
        end

        it "sets the correct last processed sequence number" do
          expect(projection.last_processed_sequence_number).to eq(128)
        end

        let(:json_events) { JSON.parse(File.read("./spec/test_data/event_data.json"), symbolize_names: true) }
        let(:aggregate_ids) { json_events.map{|event| event[:aggregate_id] }.uniq }

        it "records all aggregate ids" do
          expect(projection.aggregate_ids).to contain_exactly(*aggregate_ids)
        end
      end
    end
  end
end