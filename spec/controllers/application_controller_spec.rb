RSpec.describe ApplicationController, :type => :request do
  include ::Spec::Support::TenantIdentity
  let!(:source)     { create(:source, :tenant => tenant, :name => "abc", :uid => "123") }
  let(:client)      { instance_double("ManageIQ::Messaging::Client") }
  before do
    allow(client).to receive(:publish_topic)
    allow(Sources::Api::Messaging).to receive(:client).and_return(client)
    stub_const("ENV", "BYPASS_RBAC" => "true")
  end

  context "with tenancy enforcement" do
    it "get /source with tenant" do
      headers = { "CONTENT_TYPE" => "application/json", "x-rh-identity" => identity }

      get("/api/v1.0/sources/#{source.id}", :headers => headers)

      expect(response.status).to eq(200)
      expect(response.parsed_body).to include("id" => source.id.to_s)
    end

    it "get /source with unknown tenant" do
      headers = { "CONTENT_TYPE" => "application/json", "x-rh-identity" => unknown_identity }

      get("/api/v1.0/sources/#{source.id}", :headers => headers)

      expect(response.status).to eq(404)
      expect(Tenant.find_by(:external_tenant => unknown_tenant)).not_to be_nil
    end

    it "get /sources with tenant" do
      headers = { "CONTENT_TYPE" => "application/json", "x-rh-identity" => identity }

      get("/api/v1.0/sources", :headers => headers)

      expect(response.status).to eq(200)
    end

    it "get /sources with unknown tenant" do
      headers = { "CONTENT_TYPE" => "application/json", "x-rh-identity" => unknown_identity }

      get("/api/v1.0/sources", :headers => headers)

      expect(response.status).to eq(200)
      expect(Tenant.find_by(:external_tenant => unknown_tenant)).not_to be_nil
    end
  end

  context "with entitlement" do
    let(:entitlements) do
      {
        "hybrid_cloud" => { "is_entitled" => true },
        "insights"     => { "is_entitled" => true }
      }
    end

    it "permits request with all the necessary entitlements" do
      headers = { "CONTENT_TYPE" => "application/json", "x-rh-identity" => identity_with_entitlements }

      get("/api/v1.0/sources", :headers => headers)

      expect(response.status).to eq(200)
    end

    it "permits request with one of the necessary entitlements" do
      entitlements["insights"]["is_entitled"] = false

      headers = {
        "CONTENT_TYPE"  => "application/json",
        "x-rh-identity" => Base64.encode64(
          {'identity' => { 'account_number' => external_tenant }, :entitlements => entitlements}.to_json
        )
      }

      get("/api/v1.0/sources", :headers => headers)

      expect(response.status).to eq(200)
    end

    it "forbids request with none of the necessary entitlements" do
      entitlements["insights"]["is_entitled"]     = false
      entitlements["hybrid_cloud"]["is_entitled"] = false

      headers = {
        "CONTENT_TYPE"  => "application/json",
        "x-rh-identity" => Base64.encode64(
          {'identity' => { 'account_number' => external_tenant }, :entitlements => entitlements}.to_json
        )
      }

      get("/api/v1.0/sources", :headers => headers)

      expect(response.status).to eq(403)
    end
  end

  context "with rbac enforcement" do
    it "accepts GET request with tenancy enforcement" do
      headers = {
        "CONTENT_TYPE"  => "application/json",
        "x-rh-identity" => Base64.encode64(
          { "identity" => { "account_number" => external_tenant }}.to_json
        )
      }

      get("/api/v1.0/sources", :headers => headers)

      expect(response.status).to eq(200)
    end

    it "accepts HEAD request with tenancy enforcement" do
      headers = {
        "CONTENT_TYPE"  => "application/json",
        "x-rh-identity" => Base64.encode64(
          { "identity" => { "account_number" => external_tenant }}.to_json
        )
      }

      head("/api/v1.0/sources/#{source.id}", :headers => headers)

      expect(response.status).to eq(200)
    end

    it "accepts GET request with tenancy enforcement" do
      headers = {
        "CONTENT_TYPE"  => "application/json",
        "x-rh-identity" => Base64.encode64(
          { "identity" => { "account_number" => external_tenant }}.to_json
        )
      }

      get("/api/v1.0/sources", :headers => headers)

      expect(response.status).to eq(200)
    end

    it "accepts PATCH request with tenancy enforcement" do
      headers = {
        "CONTENT_TYPE"  => "application/json",
        "x-rh-identity" => Base64.encode64(
          { "identity" => { "account_number" => external_tenant }}.to_json
        )
      }

      patch("/api/v1.0/sources/#{source.id}", :params => { "name" => "updated_name" }.to_json, :headers => headers)

      expect(response.status).to eq(204)
    end

    it "accepts GET request with tenancy enforcement when RBAC is bypassed" do
      headers = {
        "CONTENT_TYPE"  => "application/json",
        "x-rh-identity" => Base64.encode64(
          { "identity" => { "account_number" => external_tenant }}.to_json
        )
      }

      get("/api/v1.0/sources", :headers => headers)

      expect(response.status).to eq(200)
    end

    it "accepts PATCH request with tenancy enforcement when RBAC is bypassed" do
      headers = {
        "CONTENT_TYPE"  => "application/json",
        "x-rh-identity" => Base64.encode64(
          { "identity" => { "account_number" => external_tenant }}.to_json
        )
      }

      patch("/api/v1.0/sources/#{source.id}", :params => { "name" => "updated_name" }.to_json, :headers => headers)

      expect(response.status).to eq(204)
    end
  end
end
