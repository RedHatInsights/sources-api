RSpec.describe("v3.0 - GraphQL") do
  include ::Spec::Support::TenantIdentity

  let!(:graphql_endpoint) { "/api/v3.0/graphql" }
  let!(:headers)          { { "CONTENT_TYPE" => "application/json", "x-rh-identity" => identity } }
  let!(:source_typeR) { SourceType.create(:name => "rhev_sample", :product_name => "RedHat Virtualization", :vendor => "redhat") }
  let!(:source_typeV) { SourceType.create(:name => "vmware_sample", :product_name => "VmWare vCenter", :vendor => "vmware") }
  let!(:source_typeO) { SourceType.create(:name => "openstack_sample", :product_name => "OpenStack", :vendor => "redhat") }

  context "support result sorting using the v2 interface" do
    before { stub_const("ENV", "BYPASS_TENANCY" => nil) }

    it "sort_by with a single attribute" do
      post(graphql_endpoint, :headers => headers, :params => { "query" => '
        {
          source_types(filter: { name: { ends_with: "sample" } }, sort_by: { vendor: "asc" }) {
            vendor
          }
        }' }.to_json)

      expect(response.status).to eq(200)
      expect(response.parsed_body["data"]["source_types"].collect { |st| st["vendor"] })
        .to eq(%w[redhat redhat vmware])
    end 
  end
end
