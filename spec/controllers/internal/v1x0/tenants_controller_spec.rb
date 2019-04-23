RSpec.describe Internal::V1x0::TenantsController, :type => :request do
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  it "GET an instance" do
    get(internal_v1x0_tenant_url(tenant.id), :headers => headers)

    expect(response.status).to eq(200)
    expect(response.parsed_body).to include(
      "name"            => "default",
      "external_tenant" => external_tenant
    )
  end
end
