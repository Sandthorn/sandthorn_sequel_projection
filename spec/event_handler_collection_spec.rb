require 'spec_helper'

module SandthornSequelProjection
  describe EventHandlerCollection do
    let(:collection) { EventHandlerCollection.new }

    describe "#add" do
      it "adds the handler to the collection" do
        fake_handler = Object.new
        collection.add(fake_handler)
        expect(collection.handlers).to include(fake_handler)
      end
    end


  end
end