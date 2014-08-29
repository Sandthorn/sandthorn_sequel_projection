require "spec_helper"

module SandthornSequelProjection
  describe EventHandler do

    class TestProjection
      def foo(event); event; end
    end

    let(:projection) { TestProjection.new }
    let(:simple_handler) { EventHandler.new(projection, :foo)}

    describe "::initialize" do

      context "when given just a symbol" do

        it "creates a handler with an empty filter" do
          expect(simple_handler.filter).to be_empty
        end

        it "creates a handler with the proper method handle" do
          expect(simple_handler.method).to eq(projection.method(:foo))
        end

      end

      context "when given filters" do
        let(:handler) { EventHandler.new(projection, foo: { aggregate_type: "FooBar", event_name: "new" })}
        let(:extractor) { handler.filter.matchers.matchers.first }
        let(:matching_event) { { aggregate_type: "FooBar", event_name: "new" } }

        it "creates a handler with an extract filter" do
          expect(extractor).to be_a_kind_of(SandthornEventFilter::Matchers::Extract)
          expect(extractor).to match(matching_event)
        end
      end

    end

    describe "#handle" do

      let(:event) { {foo: :bar} }

      context "when given just a symbol" do
        it "always calls the handler method" do
          input = {foo: :bar}
          expect(simple_handler.handle(event)).to eq(event)
        end
      end

      context "when given a symbol and filter" do
        let(:handler) { EventHandler.new(projection, foo: { aggregate_type: "FooBar", event_name: "new" })}
        context "when the filter matches" do
          it "calls the method" do
            allow(handler.filter).to receive(:match?) { true }
            expect(handler.handle(event)).to eq(event)
          end
        end

        context "when the filter doesn't match" do
          it "doesn't call the method" do
            allow(handler.filter).to receive(:match?) { false }
            expect(handler.handle(event)).to be_falsey
          end
        end
      end

    end
  end
end