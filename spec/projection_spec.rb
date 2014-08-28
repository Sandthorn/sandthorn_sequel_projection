require 'spec_helper'

module SandthornSequelProjection

  module MyModule
    class TestProjection < Projection
    end
  end

  describe Projection do

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
          klass.new(nil).migrate!
        end
      end

      context "when there is no migration" do
        it "does not crash" do
          klass = Class.new(Projection)
          expect { klass.new(nil).migrate! }.to_not raise_error
        end
      end
    end

  end
end