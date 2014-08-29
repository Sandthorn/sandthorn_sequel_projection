require "spec_helper"

module SandthornSequelProjection
  module Utilities
    describe NullProc do
      describe "::new" do
        it "returns a Proc that does nothing" do
          proc = NullProc.new
          expect { proc.call }.to_not raise_error
        end
      end
    end
  end
end