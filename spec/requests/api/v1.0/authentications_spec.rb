require "manageiq-messaging"

RSpec.describe("v1.0 - Authentications") do
  include ::Spec::Support::TenantIdentity

  let(:client) { instance_double("ManageIQ::Messaging::Client") }
  before do
    allow(client).to receive(:publish_topic)
    allow(Sources::Api::Messaging).to receive(:client).and_return(client)
  end

  let(:headers)         { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:collection_path) { "/api/v1.0/authentications" }
  let(:application) { create(:application, :tenant => tenant) }

  # Payload for the API request
  let(:payload) do
    {
      "username"      => "test_name",
      "password"      => "Test Password",
      "resource_type" => "Application",
      "resource_id"   => application.id.to_s
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
        create(:authentication, payload)

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(1, [a_hash_including(payload.except("password"))])
        )
      end
    end

    context "post" do
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
                              :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/Authentication/properties/extra does not define properties: amazon").to_h
                            )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => payload.merge("aaa" => "bbb").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/Authentication does not define properties: aaa").to_h
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => payload.merge("password" => 123).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::ValidateError: #/components/schemas/Authentication/properties/password expected string, but received Integer: 123").to_h
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
        instance = create(:authentication, payload)

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => payload.except("password").merge("id" => instance.id.to_s, "tenant" => tenant.external_tenant, "source_id" => application.source_id.to_s)
        )
      end

      it "failure: with an invalid id" do
        instance = create(:authentication, payload)

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>"404"}]}
        )
      end
    end

    context "patch" do
      let(:instance) { create(:authentication, payload) }
      it "success: with a valid id" do
        new_attributes = {"name" => "new name"}
        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 204,
          :parsed_body => ""
        )

        expect(instance.reload).to have_attributes(new_attributes)
      end

      it "success: with extra attributes" do
        extra_attributes = {"extra" => {"azure" => {"tenant_id" => "tenant_id_value"}}}

        patch(instance_path(instance.id), :params => extra_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(:status => 204, :parsed_body => "")
        expect(instance.reload).to have_attributes(extra_attributes)
      end

      it "failure: with an invalid id" do
        new_attributes = {"name" => "new name"}

        patch(instance_path(instance.id * 1000), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors" => [{"detail" => "Record not found", "status" => "404"}]}
        )
      end
    end
  end
end
