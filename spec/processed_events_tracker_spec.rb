require "spec_helper"

module SandthornSequelProjection
  describe ProcessedEventsTracker do

    describe "migrated specs" do
      let(:db_connection) { SandthornSequelProjection.configuration.projections_driver }
      let(:tracker) { ProcessedEventsTracker.new(:foo) }
      describe "::initialize" do
        it "ensures that the tracker row is present" do
          tracker_row = db_connection[tracker.table_name].where(identifier: tracker.identifier).first
          expect(tracker_row).to_not be_nil
          expect(tracker_row[:identifier]).to eq(tracker.identifier)
          expect(tracker_row[:last_processed_sequence_number]).to eq(0)
        end
      end

      describe '#last_processed_sequence_number' do
        it "returns the integer in the db" do
          db_connection[tracker.table_name].
            where(identifier: tracker.identifier).
            update(last_processed_sequence_number: 12)
          expect(tracker.last_processed_sequence_number).to eq(12)
        end
      end

      describe "#process_events" do
        let(:event_store) { SandthornSequelProjection.event_store }
        let(:events) { [{sequence_number: 1}, {sequence_number: 2}] }
        around do |example|
          old_batch_size = SandthornSequelProjection.batch_size
          SandthornSequelProjection.configuration.batch_size = 1
          example.run
          SandthornSequelProjection.configuration.batch_size = old_batch_size
        end

        before do
          tracker.reset
          SandthornSequelProjection.event_store.reset
          events.each { |e| event_store.add(e) }
        end

        it "yields events" do
          expect { |b| tracker.process_events(&b) }.to yield_successive_args([events.first], [events.last])
        end

        it "sets the last processed number" do
          tracker.process_events { |*| }
          expect(tracker.last_processed_sequence_number).to eq(2)
        end

        it "has the lock during the yield" do
          tracker.process_events do |*|
            expect(tracker.lock.locked?).to be_truthy
          end
        end

      end
    end

    describe "non-migrated specs" do
      let(:db_connection) { Sequel.sqlite }
      describe "::migrate!" do
        it "creates the requisite database table" do
          expect { ProcessedEventsTracker.migrate!(db_connection) }.to_not raise_error
          expect(db_connection.table_exists?(ProcessedEventsTracker.table_name)).to be_truthy
          expected_columns = :identifier, :last_processed_sequence_number, :locked_at
          expect(db_connection[ProcessedEventsTracker.table_name].columns).to include(*expected_columns)
        end
      end
    end

  end
end