describe Sources::RBAC::Access do
  context "when rbac is enabled" do
    let(:rbac_access) { instance_double(Insights::API::Common::RBAC::Access) }

    before do
      allow(described_class).to receive(:enabled?).and_return(true)
      allow(described_class).to receive(:access).and_return(rbac_access)
      allow(rbac_access).to receive(:accessible?).with("*", "*").and_return(accessible)
    end

    context "when the user has write permissions" do
      let(:accessible) { true }

      it "it allows the user access to the object" do
        expect(described_class.write_access?).to be_truthy
      end
    end

    context "when the user does not have write permissions" do
      let(:accessible) { false }

      it "does not allow the user access to the object" do
        expect(described_class.write_access?).to be_falsey
      end
    end
  end
end
