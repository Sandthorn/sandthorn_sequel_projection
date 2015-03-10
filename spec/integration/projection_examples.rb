module SandthornSequelProjection
    RSpec.shared_examples "a projection" do

    let(:projection) { described_class.new }
    let(:db_connection) { SandthornSequelProjection.configuration.db_connection }
    let(:table) { db_connection[projection.table_name] }

    context "empty" do
      it "should be empty from the start" do
        projection.migrate!
        expect(table.all).to eq([])
      end
    end

    context "mocked event data" do

      before do
        Sandthorn.default_event_store = SandthornSequelProjection::MockEventStore.with_data
      end

      describe "#update" do
        before(:each) do
          projection.migrate!
        end
        methods = [:product_added, :removed_from_sale]
        methods.each do |method|
          it "calls #{method}" do
            expect(projection).to receive(method).at_least(:once).and_call_original
            projection.update!
          end
        end

        describe "mocked event data" do
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

      context "event data from db" do
        before do
          setup_db_event_store
          @product_on_sale = SandthornProduct.new
          @product_on_sale.put_on_sale
          @product_on_sale.save

          @product_not_on_sale = SandthornProduct.new
          @product_not_on_sale.put_on_sale
          @product_not_on_sale.remove_from_sale
          @product_not_on_sale.save

          projection.migrate!
          projection.update!
        end

        after(:each) do
          clear_event_store  
        end

        describe "event data from db based event store" do
          it "should gets all aggregate" do
            expect(projection.aggregate_ids().length).to eq(2)
          end

          it "should only return products on sale" do
            expect(projection.aggregates_on_sale_ids().length).to eq(1)
            expect(projection.aggregates_on_sale_ids.first).to eq(@product_on_sale.aggregate_id)
          end

          it "records all aggregate ids" do
            expect(projection.aggregate_ids).to contain_exactly(*[@product_on_sale.aggregate_id, @product_not_on_sale.aggregate_id])
          end
        end
      end
    end
  end
end