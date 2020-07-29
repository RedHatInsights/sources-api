describe Api::V1::Mixins::ShowMixin do
  describe Api::V1x0::SourcesController, :type => :request do
    include ::Spec::Support::TenantIdentity

    let(:headers)     { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
    let!(:source_1)   { create(:source, :name => "test_source 1") }
    let!(:source_2)   { create(:source, :name => "test_source 2") }

    it "Primary Collection: get /sources lists all Sources" do
      get(api_v1x0_source_url(source_1.id), :headers => headers)

      expect(response.status).to eq(200)
      expect(response.parsed_body).to include("id" => source_1.id.to_s, "name" => source_1.name)
    end

    context "Sub-collection:" do
      let!(:endpoint_1) { create(:endpoint, :role => "a", :source => source_1) }

      it "get /sources/:id/endpoints/:id doesn't exist" do
        get(api_v1x0_source_endpoints_url(source_1.id) + "/#{endpoint_1.id}", :headers => headers)

        expect(response.status).to eq(404)
      end
    end
  end
end
