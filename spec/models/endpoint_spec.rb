describe Endpoint do
  describe "#base_url_path" do
    let(:endpoint) { described_class.new(:host => "www.example.com", :port => 1234, :scheme => "https") }

    it "combines the various attributes to create a full url" do
      expect(endpoint.base_url_path).to eq("https://www.example.com:1234")
    end
  end

  describe "#default" do
    let(:source_type) { SourceType.find_or_create_by!(:name => "amazon", :product_name => "Amazon Web Services", :vendor => "Amazon") }
    let(:tenant) { Tenant.create!(:external_tenant => SecureRandom.uuid) }
    let(:source) { Source.create!(:name => "my-source", :tenant => tenant, :source_type => source_type) }

    it "allows only one default endpoint" do
      described_class.create!(:role => "first", :default => true, :tenant => tenant, :source => source)
      expect { described_class.create!(:role => "second", :default => true, :tenant => tenant, :source => source) }.to raise_exception
    end

    it "sets the first endpoint created as default" do
      endpoint = described_class.create!(:role => "first", :tenant => tenant, :source => source)
      expect(endpoint.default).to be_truthy

      endpoint2 = described_class.create!(:role => "second", :tenant => tenant, :source => source)
      expect(endpoint2.default).to be_falsey
    end

    it "sets default on an endpoint that gets re-added" do
      endpoint = described_class.create!(:role => "first", :tenant => tenant, :source => source)
      expect(endpoint.default).to be_truthy

      endpoint.delete

      endpoint2 = described_class.create!(:role => "second", :tenant => tenant, :source => source)
      expect(endpoint2.default).to be_truthy
    end
  end
end
