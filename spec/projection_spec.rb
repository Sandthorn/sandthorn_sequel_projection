require 'spec_helper'

module SandthornSequelProjection

  module MyModule
    class TestProjection < Projection

      def foo

      end

      def bar

      end

    end

    class WithHandlers < TestProjection

      define_event_handlers do |handlers|
        handlers.define(:foo)
        handlers.define(:bar)
      end

    end
  end

  describe Projection do
    let(:projection) { MyModule::WithHandlers.new }

    describe "::initialize" do
      it "sets the handlers on the instance" do
        handlers = projection.event_handlers
        expect(handlers.length).to eq(2)
      end
    end

    describe '::identifier' do
      it "snake cases the class identifier" do
        expect(MyModule::TestProjection.identifier).to eq("sandthorn_sequel_projection_my_module_test_projection")
      end
    end

    describe "#identifier" do
      it "snake cases the class identifier" do
        expect(MyModule::TestProjection.new.identifier).to eq("sandthorn_sequel_projection_my_module_test_projection")
      end
    end

    describe "#update!" do

      before do
        event_store = Sandthorn.default_event_store
        event_store.reset
        event_store.add_event({sequence_number: 1, event_args: {}})
        event_store.add_event({sequence_number: 2, event_args: {}})
      end

      it "fetches events and passes them on to the handlers" do
        projection = MyModule::WithHandlers.new
        handlers = projection.event_handlers
        handlers.each do |handler|
          expect(handler).to receive(:handle).twice
        end
        projection.update!
      end
    end

    describe "::event_store" do
      let(:klass) { Class.new(Projection) }
      context "when given an event store name" do
        it "sets the event store" do
          klass.event_store(:foo)
          expect(klass.event_store_name).to eq(:foo)
        end
      end

      context "when given no argument" do
        context "when an event store has been configured" do
          before do
            klass.event_store(:foo)
          end
          it "fetches the event store" do
            expect(SandthornSequelProjection).to receive(:find_event_store).with(:foo)
            klass.event_store
          end 
        end
      end
    end

    describe "::define_event_handlers" do
      it "yields an EventHandlerCollection" do
        expect { |b| MyModule::TestProjection.define_event_handlers(&b) }.to yield_with_args(EventHandlerCollection)
      end
    end
  end
end