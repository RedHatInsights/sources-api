describe Internal::V2x0::Mixins::IndexMixin do
  describe Internal::V2x0::SourcesController, :type => :request do
    include ::Spec::Support::TenantIdentity

    let(:headers)      { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
    let!(:tenant2)           { Tenant.create!(:name => "2nd tenant", :external_tenant => external_tenant2) }
    let!(:external_tenant2)  { rand(1000).to_s }

    let!(:source_1)    { create(:source, :name => "source 1 tenant 1", :tenant => tenant) }
    let!(:source_2)    { create(:source, :name => "source 2 tenant 1", :tenant => tenant) }
    let!(:source_3)    { create(:source, :name => "source 3 tenant 2", :tenant => tenant2) }

    it "Primary Collection: get /sources lists all Sources" do
      get(internal_v2x0_sources_url, :headers => headers)

      expect(response.status).to eq(200)
      expect(response.parsed_body["data"]).to match([a_hash_including("id" => source_1.id.to_s),
                                                     a_hash_including("id" => source_2.id.to_s),
                                                     a_hash_including("id" => source_3.id.to_s)])
    end

    context "paging" do
      it "response_structure" do
        get(internal_v2x0_sources_url, :headers => headers)

        expect(response.status).to eq(200)
        expect(response.parsed_body.keys).to eq(["meta", "links", "data"])
      end

      it "meta/count" do
        get(internal_v2x0_sources_url, :headers => headers)

        expect(response.status).to eq(200)
        expect(response.parsed_body["meta"]).to eq("count" => 3, "limit" => 100, "offset" => 0)
      end
    end
  end
end
