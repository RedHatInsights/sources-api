describe Authentication do
  describe "#authtype_not_updated" do
    let(:source_type) { SourceType.find_or_create_by!(:name => "amazon", :product_name => "Amazon Web Services", :vendor => "Amazon") }
    let(:tenant) { Tenant.create!(:external_tenant => SecureRandom.uuid) }
    let(:source) { Source.create!(:name => "my-source", :tenant => tenant, :source_type => source_type) }
    let(:endpoint) { Endpoint.create!(:host => 'www.example.com', :tenant => tenant, :source => source) }

    it "can create authentication with any authtype" do
      expect { described_class.create!(:resource => endpoint, :authtype => 'username_password', :tenant => tenant) }.not_to raise_exception
    end

    it "can't update authentication's authtype" do
      auth = described_class.create!(:resource => endpoint, :authtype => 'username_password', :tenant => tenant)

      expect { auth.update!(:name => 'my_auth') }.not_to raise_exception
      expect { auth.update!(:authtype => 'token') }.to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
