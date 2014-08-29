require 'spec_helper'

module SandthornSequelProjection

  module MyModule
    class TestProjection < Projection

      def foo

      end

      def bar

      end

    end
  end

  describe Projection do

    describe "::initialize" do
      it "sets the handlers on the instance" do
        MyModule::TestProjection.define_event_handlers do |handlers|
          handlers.add(:foo)
          handlers.add(:bar)
        end
        projection = MyModule::TestProjection.new
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

    describe "::define_event_handlers" do
      it "yields an EventHandlerCollection" do
        expect { |b| MyModule::TestProjection.define_event_handlers(&b) }.to yield_with_args(EventHandlerCollection)
      end
    end

  end
end