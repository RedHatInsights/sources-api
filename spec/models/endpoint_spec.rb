describe Endpoint do
  describe "#base_url_path" do
    let(:endpoint) { described_class.new(:host => "www.example.com", :port => 1234, :scheme => "https") }

    it "combines the various attributes to create a full url" do
      expect(endpoint.base_url_path).to eq("https://www.example.com:1234")
    end
  end
end
