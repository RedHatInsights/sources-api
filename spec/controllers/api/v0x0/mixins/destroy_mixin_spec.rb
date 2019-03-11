describe Api::V0::Mixins::DestroyMixin do
  describe Api::V0x0::SourcesController, :type => :request do
    let!(:source_1)   { Source.create!(:source_type => source_type, :tenant => tenant, :name => "test_source 1", :uid => SecureRandom.uuid) }
    let!(:tenant)     { Tenant.create! }
    let(:source_type) { SourceType.create!(:name => "openshift", :product_name => "OpenShift", :vendor => "Red Hat") }

    it "Primary Collection: delete /sources/:id destroys a Source" do
      delete(api_v0x0_source_url(source_1.id))

      expect(response.status).to eq(204)
      expect(response.parsed_body).to be_empty
    end

    context "Sub-collection:" do
      let!(:endpoint_1) { Endpoint.create!(:role => "a", :source => source_1, :tenant => tenant) }

      it "delete /sources/:id/endpoint/:id fails with 404" do
        delete(api_v0x0_source_endpoints_url(source_1.id) + "/#{endpoint_1.id}")

        expect(response.status).to eq(404)
      end
    end
  end
end
