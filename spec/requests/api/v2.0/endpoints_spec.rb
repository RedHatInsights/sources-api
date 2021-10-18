require "manageiq-messaging"

RSpec.describe("v2.0 - Endpoints") do
  include ::Spec::Support::TenantIdentity

  let(:client) { instance_double("ManageIQ::Messaging::Client") }
  before do
    allow(client).to receive(:publish_topic)
    allow(Sources::Api::Messaging).to receive(:client).and_return(client)
  end

  let(:headers)         { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:collection_path) { "/api/v2.0/endpoints" }
  let(:source)          { create(:source, :tenant => tenant) }

  let(:payload) do
    {
      "host"                  => "example.com",
      "port"                  => 443,
      "role"                  => "default",
      "path"                  => "api",
      "source_id"             => source.id.to_s,
      "scheme"                => "https",
      "verify_ssl"            => true,
      "certificate_authority" => "-----BEGIN CERTIFICATE-----\nabcd\n-----END CERTIFICATE-----",
    }
  end

  describe("/api/v2.0/endpoints") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        create(:endpoint, payload.merge(:tenant => tenant))

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(1, [a_hash_including(payload)])
        )

      end
    end

    context "post" do
      it "success: with valid body" do
        stub_const("ENV", "BYPASS_RBAC" => "true")
        post(collection_path, :params => payload.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 201,
          :location => "http://www.example.com/api/v2.0/endpoints/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(payload)
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => payload.merge("aaa" => "bbb").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/Endpoint does not define properties: aaa").to_h
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => payload.merge("default" => 123).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::ValidateError: #/components/schemas/Endpoint/properties/default expected boolean, but received Integer: 123").to_h
        )
      end
    end
  end

  describe("/api/v2.0/endpoints/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = create(:endpoint, payload.merge(:tenant => tenant))

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => a_hash_including("id" => instance.id.to_s, "tenant" => tenant.external_tenant)
        )
      end

      it "failure: with an invalid id" do
        instance = create(:endpoint, payload.merge(:tenant => tenant))

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>"404"}]}
        )
      end
    end

    context "patch" do
      let(:instance) { create(:endpoint, payload.merge(:tenant => tenant)) }

      it "update availability status" do
        stub_const("ENV", "BYPASS_RBAC" => "true")
        expect(Sources::Api::Events).to receive(:raise_event).twice

        included_attributes = {"availability_status" => "available"}
        patch(instance_path(instance.id), :params => included_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(:status => 204, :parsed_body => "")
      end

      it "success: with a valid id" do
        stub_const("ENV", "BYPASS_RBAC" => "true")
        new_attributes = {"host" => "example.org"}
        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 204,
          :parsed_body => ""
        )

        expect(instance.reload).to have_attributes(new_attributes)
      end

      it "failure: with extra attributes" do
        extra_attributes = {"aaa" => "bbb"}

        patch(instance_path(instance.id), :params => extra_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/Endpoint does not define properties: aaa").to_h
        )
      end

      it "failure: with an invalid id" do
        new_attributes = {"host" => "example.org"}

        patch(instance_path(instance.id * 1000), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors" => [{"detail" => "Record not found", "status" => "404"}]}
        )
      end
    end
  end
end
