module SandthornSequelProjection
  describe MockEventStore do
    let(:store) { MockEventStore.new }
    describe "get_events" do
      context "when there are events" do
        before do
          store.add_event({sequence_number: 1, event_args: { foo: "bar" } })
        end
        it "returns events with serialized event data" do
          events = store.get_events
          event = events.first
          expect(event[:event_data]).to eq(YAML.dump(event[:event_args]))
        end

        it "returns the correct amount of events" do
          store.add_event({sequence_number: 2, event_args: { foo: "bar"} })
          expect(store.get_events(take: 2).length).to eq(2)
          expect(store.get_events(take: 1).length).to eq(1)
        end
      end

      context "when there's no events" do
        it "return the empty array" do
          expect(store.get_events).to be_empty
        end
      end
    end
  end
end

