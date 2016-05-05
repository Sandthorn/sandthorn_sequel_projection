module SandthornSequelProjection
  describe Cursor do

    let(:first_page) { [ { sequence_number: "1" } ] }
    let(:second_page) { [ { sequence_number: "2" } ] }
    let(:third_page) { [] }
    let(:event_store) do
      store = Object.new
      env = self
      store.tap do |store|
        store.define_singleton_method(:get_events) do |after_event: "0", take: 1|
          case after_event
            when "0"
              env.first_page
            when "1"
              env.second_page
            else
              env.third_page
          end
        end
      end
    end
    let(:cursor) { Cursor.new(after_event: "0", batch_size: 1, event_store: event_store) }

    it "has the correct starting sequence number and batch size" do
      expect(cursor.batch_size).to eq(1)
      expect(cursor.last_event).to eq("0")
    end

    describe "#get_batch" do
      describe "sequential calls" do
        it "returns pages until empty and keeps track of seen sequence numbers" do
          expect(cursor.get_batch.events).to eq(first_page)
          expect(cursor.last_event).to eq(first_page.last[:sequence_number])
          expect(cursor.get_batch.events).to eq(second_page)
          expect(cursor.last_event).to eq(second_page.last[:sequence_number])
          expect(cursor.get_batch.events).to eq(third_page)
          expect(cursor.last_event).to eq(second_page.last[:sequence_number])
        end
      end
    end

  end
end