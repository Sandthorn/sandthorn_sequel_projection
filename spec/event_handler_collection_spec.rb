require 'spec_helper'

module SandthornSequelProjection
  describe EventHandlerCollection do
    let(:collection) { EventHandlerCollection.new }
    let(:projection) { Object.new }

    describe "#add" do
      it "adds the handler to the collection" do
        handler_data = :foo
        collection.define(handler_data)
        expect(collection.handlers.length).to eq(1)
        handler = collection.handlers.first
        expect(handler.message).to eq(:foo)
      end
    end

    describe "#handle" do
      it "calls handle on each handler for every event, in order" do
        events = [1,2]
        handler1 = :foo
        handler2 = :bar
        handlers = [handler1, handler2]
        handlers.each do |handler|
          collection.define(handler)
        end
        collection.handlers.each do |handler|
          expect(handler).to receive(:handle).ordered.with(projection, 1).once
        end
        collection.handlers.each do |handler|
          expect(handler).to receive(:handle).ordered.with(projection, 2).once
        end
        collection.handle(projection, events)
      end
    end


  end
end