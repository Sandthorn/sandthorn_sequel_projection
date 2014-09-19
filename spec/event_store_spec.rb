require 'spec_helper'

module SandthornSequelProjection
  describe EventStore do
    describe "#initialize" do
      context "when not given an event store" do
        context "when Sandthorn is defined" do

          around do |example|
            overridden = false
            unless defined?(::Sandthorn)
              overridden = true
              ::Sandthorn = Struct.new(:get_events).new(:foo)
            end
            example.run
            if overridden
              Object.send(:remove_const, :Sandthorn)
            end
          end

          it "returns Sandthorn" do
            expect(defined?(::Sandthorn)).to be_truthy
            expect { EventStore.new }.to_not raise_error
            store = EventStore.new
            expect(store).to eq(Sandthorn)
          end
        end

        context "when Sandthorn isn't defined" do
          it "raises an exception" do
            expect(defined?(::Sandthorn)).to be_falsey
            expect { EventStore.new }.to raise_error
          end
        end
      end

      context "when given an event store" do
        class FakeStore
          def get_events; end
        end
        context "when given a valid event store" do
          it "should not raise an error" do
            store = FakeStore.new
            expect { EventStore.new(store) }.to_not raise_error
          end
        end

        context "when given an invalid event store" do
          it "should raise InvalidEventStore error" do
            store = double
            expect { EventStore.new(store) }.to raise_error(InvalidEventStoreError)
          end
        end
      end
    end
  end
end