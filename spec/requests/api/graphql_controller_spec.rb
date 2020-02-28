RSpec.describe("v1.0 - GraphQL") do
  include ::Spec::Support::TenantIdentity
  let!(:source_type) { SourceType.create!(:name => "SourceType", :vendor => "Some Vendor", :product_name => "Product Name") }
  let!(:source)      { Source.create!(:tenant_id => tenant.id, :name => "sample_source", :source_type => source_type, :uid => "123") }

  let!(:graphql_source_query) { { "query" => "{ sources(id: \"#{source.id}\") { tenant } }" }.to_json }

  def result_source_tenant(response_body)
    JSON.parse(response_body).fetch_path("data", "sources").collect { |source| source["tenant"] }
  end

  context "querying source tenant" do
    before { stub_const("ENV", "BYPASS_TENANCY" => nil) }

    it "returns the external tenant identifier" do
      headers = { "CONTENT_TYPE" => "application/json", "x-rh-identity" => identity }

      post("/api/v1.0/graphql", :headers => headers, :params => graphql_source_query)

      expect(response.status).to eq(200)
      expect(result_source_tenant(response.body)).to match_array([tenant.external_tenant])
    end

    it "with non-org-admin: returns the external tenant identifier" do
      headers = { "CONTENT_TYPE" => "application/json", "x-rh-identity" => non_org_admin_identity }

      post("/api/v1.0/graphql", :headers => headers, :params => graphql_source_query)

      expect(response.status).to eq(200)
      expect(result_source_tenant(response.body)).to match_array([tenant.external_tenant])
    end
  end
end
