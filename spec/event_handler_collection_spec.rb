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

    describe "#handle" do
      it "calls handle on each handler for every event, in order" do
        events = [1,2]
        handler1 = double
        handler2 = double
        handlers = [handler1, handler2]
        handlers.each do |handler|
          collection.add(handler)
        end
        handlers.each do |handler|
          expect(handler).to receive(:handle).ordered.with(1).once
        end
        handlers.each do |handler|
          expect(handler).to receive(:handle).ordered.with(2).once
        end
        collection.handle(events)
      end
    end


  end
end