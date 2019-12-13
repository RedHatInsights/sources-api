describe ApplicationType do
  describe ".seed" do
    it "first time" do
      described_class.seed

      expect(described_class.find_by(:name => "/insights/platform/topological-inventory")).to be
    end

    it "multiple times" do
      described_class.seed

      original = described_class.pluck(:id, :updated_at)

      described_class.seed

      expect(described_class.pluck(:id, :updated_at)).to match_array original
    end
  end
end
