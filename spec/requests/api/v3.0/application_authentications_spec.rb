RSpec.describe("v3.0 - ApplicationAuthentications") do
  include ::Spec::Support::TenantIdentity

  let(:messaging_client) { instance_double("ManageIQ::Messaging::Client") }
  before do
    allow(messaging_client).to receive(:publish_topic)
    allow(Sources::Api::Messaging).to receive(:client).and_return(messaging_client)
  end

  let(:headers)          { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:endpoint)         { create(:endpoint) }
  let(:authentication)   { create(:authentication, :resource => endpoint) }
  let(:application)      { create(:application) }
  let(:attributes)       { {"application_id" => application.id.to_s, "authentication_id" => authentication.id.to_s } }
  let(:collection_path)  { "/api/v3.0/application_authentications" }
  let(:payload) do
    {
      "application_id"    => application.id.to_s,
      "authentication_id" => authentication.id.to_s
    }
  end

  describe("/api/v3.0/application_authentication") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        create(:application_authentication, attributes)

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes)])
        )
      end
    end

    context "post" do
      it "success: with valid body" do
        stub_const("ENV", "BYPASS_RBAC" => "true")
        post(collection_path, :params => payload.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 201,
          :location => "http://www.example.com/api/v3.0/application_authentications/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(payload)
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => payload.merge("aaa" => "bbb").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/ApplicationAuthentication does not define properties: aaa").to_h
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => payload.merge("application_id" => 123).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::ValidateError: #/components/schemas/ID expected string, but received Integer: 123").to_h
        )
      end
    end
  end

  describe("/api/v3.0/application_types/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = create(:application_authentication, attributes)

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s))
        )
      end

      it "failure: with an invalid id" do
        instance = create(:application_authentication, attributes)

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors" => [{"detail" => "Record not found", "status" => "404"}]}
        )
      end
    end


    context "delete" do
      it "success: with a valid paylod" do
        stub_const("ENV", "BYPASS_RBAC" => "true")
        record = create(:application_authentication, payload)

        expect(Sources::Api::Events).to receive(:raise_event).once
        delete(instance_path(record.id), :headers => headers)

        expect(response.status).to eq(204)
        expect(response.parsed_body).to be_empty
      end
    end
  end
end
