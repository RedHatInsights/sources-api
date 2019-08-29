require "manageiq-messaging"

RSpec.describe("v1.0 - Authentications") do
  include ::Spec::Support::TenantIdentity

  let(:headers)         { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:collection_path) { "/api/v1.0/authentications" }
  let(:payload) do
    {
      "username"      => "test_name",
      "password"      => "Test Password",
      "resource_type" => "Tenant",
      "resource_id"   => tenant.id.to_s
    }
  end

  describe("/api/v1.0/authentications") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        Authentication.create!(payload.merge(:tenant => tenant))

        get(collection_path, :headers => headers)

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
        post(collection_path, :params => payload.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 201,
          :location => "http://www.example.com/api/v1.0/authentications/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(payload.except("password"))
        )
      end

      it "success: with valid body containing extra" do
        payload_with_extra = payload.merge(:extra => {:azure => {:tenant_id => "tenant_id_value"}})
        post(collection_path, :params => payload_with_extra.to_json, :headers => headers)

        expect(response).to have_attributes(
                              :status => 201,
                              :location => "http://www.example.com/api/v1.0/authentications/#{response.parsed_body["id"]}",
                              :parsed_body => a_hash_including(payload.except("password"))
                            )
        expect(response.parsed_body["extra"]).to match({"azure" => {"tenant_id" => "tenant_id_value"}})
      end

      it "failure: with valid body containing invalid extra" do
        payload_with_extra = payload.merge({:extra => {:amazon => {:tenant_id => "tenant_id_value"}}})
        post(collection_path, :params => payload_with_extra.to_json, :headers => headers)

        expect(response).to have_attributes(
                              :status => 400,
                              :location => nil,
                              :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "properties amazon are not defined in #/components/schemas/Authentication/properties/extra").to_h
                            )
      end

      it "failure: with no body" do
        post(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "Failed to parse POST body, expected JSON").to_h
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => payload.merge("aaa" => "bbb").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "properties aaa are not defined in #/components/schemas/Authentication").to_h
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => payload.merge("password" => 123).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "123 class is Integer but it's not valid string in #/components/schemas/Authentication/properties/password").to_h
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
        instance = Authentication.create!(payload.merge(:tenant => tenant))

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => payload.except("password").merge("id" => instance.id.to_s, "tenant" => tenant.external_tenant)
        )
      end

      it "failure: with an invalid id" do
        instance = Authentication.create!(payload.merge(:tenant => tenant))

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>404}]}
        )
      end
    end
  end
end
