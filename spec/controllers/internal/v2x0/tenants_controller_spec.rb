RSpec.describe Internal::V2x0::TenantsController, :type => :request do
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  it "GET an instance" do
    get(internal_v2x0_tenant_url(tenant.id), :headers => headers)

    expect(response.status).to eq(200)
    expect(response.parsed_body).to include(
                                      "name"            => "default",
                                      "external_tenant" => external_tenant
                                    )
  end

  context "paging" do
    let!(:tenant2)           { create(:tenant, :name => "Alice", :external_tenant => external_tenant2) }
    let!(:tenant3)           { create(:tenant, :name => "Bob", :external_tenant => external_tenant2) }
    let!(:external_tenant2)  { rand(1000).to_s }
    let!(:external_tenant3)  { rand(1000).to_s }

    it "response_structure" do
      get(internal_v2x0_tenants_url, :headers => headers)

      expect(response.status).to eq(200)
      expect(response.parsed_body.keys).to eq(["meta", "links", "data"])
    end

    it "meta/count" do
      get(internal_v2x0_tenants_url, :headers => headers)

      expect(response.status).to eq(200)
      expect(response.parsed_body["meta"]).to eq("count" => 3, "limit" => 100, "offset" => 0)
    end

    it "2nd page" do
      get(internal_v2x0_tenants_url(:limit => 2, :offset => 2), :headers => headers)

      expect(response.status).to eq(200)
      expect(response.parsed_body["meta"]).to eq("count" => 3, "limit" => 2, "offset" => 2)
      expect(response.parsed_body['data'].size).to eq(1)
    end
  end
end
