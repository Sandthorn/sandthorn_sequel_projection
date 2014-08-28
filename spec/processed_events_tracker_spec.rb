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

      describe "#set_last_processed_sequence_number" do
        context "when the row isn't locked" do
          it "sets it" do
            tracker.set_last_processed_sequence_number(127)
            expect(tracker.last_processed_sequence_number).to eq(127)
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