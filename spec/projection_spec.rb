require 'spec_helper'

module SandthornSequelProjection
  describe Projection do

    describe '.update!' do
      context "when subclass doesn't override" do
        it "raises an error" do
          klass = Class.new(Projection)
          expect {klass.new.update!}.to raise_error(NotImplementedError)
        end
      end
    end

    describe ".migrate!" do
      context "there is a migration" do
        it "runs the defined migration" do

        end
      end

      context "when there is no migration" do
        it "does not crash" do
          klass = Class.new(Projection)
          expect { klass.migrate!(Object.new) }.to_not raise_error
        end
      end
    end

  end
end