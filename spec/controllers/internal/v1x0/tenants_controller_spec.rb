RSpec.describe Internal::V1x0::TenantsController, :type => :request do
  let(:tenant) { Tenant.find_or_create_by!(:name => "default", :external_tenant => "external_tenant_uuid")}

  it "GET an instance" do
    get(internal_v1x0_tenant_url(tenant.id))

    expect(response.status).to eq(200)
    expect(response.parsed_body).to include(
      "name"            => "default",
      "external_tenant" => "external_tenant_uuid"
    )
  end
end
