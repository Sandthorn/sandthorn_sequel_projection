module SandthornSequelProjection
  describe Runner do

    module FakeProjection
      def initialize(*); end
      def migrate!; end
      def update!; end
    end

    class Projection1; include FakeProjection; end
    class Projection2; include FakeProjection; end

    let(:manifest) { Manifest.new(Projection1, Projection2) }

    let(:runner) { SandthornSequelProjection::Runner.new(manifest) }

    describe "#run" do
      it "migrates all projections" do
        expect_any_instance_of(Projection1).to receive(:migrate!).once
        expect_any_instance_of(Projection2).to receive(:migrate!).once
        runner.run(false)
      end

      it "updates all projections" do
        expect_any_instance_of(Projection1).to receive(:update!).once
        expect_any_instance_of(Projection2).to receive(:update!).once
        runner.run(false)
      end
    end

  end
end