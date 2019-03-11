describe Api::V0x1::Mixins::IndexMixin do
  describe Api::V0x1::SourcesController, :type => :request do
    let!(:source_1)    { Source.create!(:source_type => source_type, :tenant => tenant, :name => "test_source 1", :uid => SecureRandom.uuid) }
    let!(:source_2)    { Source.create!(:source_type => source_type, :tenant => tenant, :name => "test_source 2", :uid => SecureRandom.uuid) }
    let!(:source_type) { SourceType.create!(:name => "openshift", :product_name => "OpenShift", :vendor => "Red Hat") }
    let!(:tenant)      { Tenant.create! }

    it "Primary Collection: get /sources lists all Sources" do
      get(api_v0x1_sources_url)

      expect(response.status).to eq(200)
      expect(response.parsed_body["data"]).to match([a_hash_including("id" => source_1.id.to_s), a_hash_including("id" => source_2.id.to_s)])
    end

    context "Sub-collection:" do
      let!(:endpoint_1) { Endpoint.create!(:role => "a", :source => source_1, :tenant => tenant) }
      let!(:endpoint_2) { Endpoint.create!(:role => "b", :source => source_1, :tenant => tenant) }
      let!(:endpoint_3) { Endpoint.create!(:role => "c", :source => source_2, :tenant => tenant) }

      it "get /sources/:id/endpoints lists all Endpoints for a source" do
        get(api_v0x1_source_endpoints_url(source_1.id))

        expect(response.status).to eq(200)
        expect(response.parsed_body["data"]).to match([a_hash_including("id" => endpoint_1.id.to_s), a_hash_including("id" => endpoint_2.id.to_s)])
      end
    end

    context "paging" do
      it "response_structure" do
        get(api_v0x1_sources_url)

        expect(response.status).to eq(200)
        expect(response.parsed_body.keys).to eq(["meta", "links", "data"])
      end

      it "meta/count" do
        get(api_v0x1_sources_url)

        expect(response.status).to eq(200)
        expect(response.parsed_body["meta"]).to eq("count" => 2, "limit" => 100, "offset" => 0)
      end
    end
  end
end
