RSpec.describe Internal::V0x0::AuthenticationsController, :type => :request do
  let(:authentication) { Authentication.create!(:resource => endpoint, :tenant => tenant, :password => "abcdefg") }
  let(:endpoint)       { Endpoint.create!(:source => source, :tenant => tenant) }
  let(:source)         { Source.create!(:source_type => source_type, :tenant => tenant, :uid => SecureRandom.uuid, :name => "test_source") }
  let(:source_type)    { SourceType.create!(:name => "openshift", :product_name => "OpenShift", :vendor => "Red Hat") }
  let(:tenant)         { Tenant.create! }

  it "GET an instance" do
    get(internal_v0x0_authentication_url(authentication.id))

    expect(response.status).to eq(200)
    expect(response.parsed_body).to include("id" => authentication.id.to_s, "resource_type" => "Endpoint", "resource_id" => endpoint.id.to_s)
    expect(response.parsed_body.keys).not_to include("password")
  end

  it "GET an instance exposing password" do
    get(internal_v0x0_authentication_url(authentication.id), :params => {"expose_encrypted_attribute[]" => "password"})

    expect(response.status).to eq(200)
    expect(response.parsed_body).to include("id" => authentication.id.to_s, "resource_type" => "Endpoint", "resource_id" => endpoint.id.to_s, "password" => "abcdefg")
  end
end
