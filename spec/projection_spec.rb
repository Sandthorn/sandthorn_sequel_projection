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

    describe "::initialize" do
      it "sets the handlers on the instance" do
        projection = MyModule::WithHandlers.new
        handlers = projection.event_handlers
        expect(handlers.length).to eq(2)
      end
    end

    describe '::identifier' do
      it "snake cases the class identifier" do
        expect(MyModule::TestProjection.identifier).to eq("sandthorn_sequel_projection_my_module_test_projection")
      end
    end

    describe "#migrate!" do
      context "there is a migration" do
        it "runs the defined migration" do
          klass = Class.new(Projection)
          block = Proc.new {}
          klass.define_migration(block)
          expect(block).to receive(:call)
          klass.new.migrate!
        end
      end

      context "when there is no migration" do
        it "does not crash" do
          klass = Class.new(Projection)
          expect { klass.new(nil).migrate! }.to_not raise_error
        end
      end
    end

    describe "#update!" do

      before do
        event_store = SandthornSequelProjection.event_store
        event_store.reset
        event_store.add_event({sequence_number: 1})
        event_store.add_event({sequence_number: 2})
        SandthornSequelProjection.configure do |c|
          c.projections_driver = Sequel.sqlite
        end
        SandthornSequelProjection.start
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

    describe "::define_event_handlers" do
      it "yields an EventHandlerCollection" do
        expect { |b| MyModule::TestProjection.define_event_handlers(&b) }.to yield_with_args(EventHandlerCollection)
      end
    end

  end
end