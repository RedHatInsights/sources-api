require "manageiq-messaging"

RSpec.describe("v1.0 - Authentications") do
  include ::Spec::Support::TenantIdentity

  let(:collection_path) { "/api/v1.0/authentications" }
  let(:tenant)          { Tenant.create!(:external_tenant => SecureRandom.uuid) }
  let(:attributes)      { payload.except("tenant").merge("tenant" => tenant) }
  let(:payload) do
    {
      "username"      => "test_name",
      "password"      => "Test Password",
      "tenant"        => tenant.external_tenant,
      "resource_type" => "Tenant",
      "resource_id"   => tenant.id.to_s
    }
  end

  describe("/api/v1.0/authentications") do
    context "get" do
      it "success: empty collection" do
        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        Authentication.create!(attributes)

        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(1, [a_hash_including(payload.except("password"))])
        )
      end
    end

    context "post" do
      let(:client) { instance_double("ManageIQ::Messaging::Client") }
      before do
        allow(client).to receive(:publish_topic)
        allow(Sources::Api::Events).to receive(:messaging_client).and_return(client)
      end

      it "success: with valid body" do
        post(collection_path, :params => payload.to_json)

        expect(response).to have_attributes(
          :status => 201,
          :location => "http://www.example.com/api/v1.0/authentications/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(payload.except("password"))
        )
      end

      it "failure: with no body" do
        post(collection_path)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "Failed to parse POST body, expected JSON").to_h
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => payload.merge("aaa" => "bbb").to_json)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "found unpermitted parameter: :aaa").to_h
        )
      end
    end
  end

  describe("/api/v1.0/authentications/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = Authentication.create!(attributes)

        get(instance_path(instance.id))

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => payload.except("password").merge("id" => instance.id.to_s)
        )
      end

      it "failure: with an invalid id" do
        instance = Authentication.create!(attributes)

        get(instance_path(instance.id * 1000))

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Couldn't find Authentication with 'id'=#{instance.id * 1000}", "status"=>404}]}
        )
      end
    end
  end
end
