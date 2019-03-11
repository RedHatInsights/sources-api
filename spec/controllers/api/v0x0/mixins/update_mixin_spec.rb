describe Api::V0::Mixins::UpdateMixin do
  describe Api::V0x0::SourcesController, :type => :request do
    let(:source_type) { SourceType.create!(:name => "openshift", :product_name => "OpenShift", :vendor => "Red Hat") }
    let(:tenant)      { Tenant.create! }

    it "patch /sources/:id updates a Source" do
      source = Source.create!(:source_type => source_type, :tenant => tenant, :name => "abc", :uid => SecureRandom.uuid)

      patch(api_v0x0_source_url(source.id), :params => {:name => "xyz"}.to_json)

      expect(source.reload.name).to eq("xyz")

      expect(response.status).to eq(204)
      expect(response.parsed_body).to be_empty
    end
  end
end
