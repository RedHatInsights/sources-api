require "manageiq-messaging"

RSpec.describe("v1.0 - SourceTypes") do
  include ::Spec::Support::TenantIdentity

  let(:headers)         { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:attributes)      { {"name" => "test_name", "product_name" => "Test Product", "vendor" => "TestVendor"} }
  let(:collection_path) { "/api/v1.0/source_types" }

  describe("/api/v1.0/source_types") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        SourceType.create!(attributes)

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes)])
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
        post(collection_path, :params => attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 201,
          :location => "http://www.example.com/api/v1.0/source_types/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(attributes)
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => attributes.merge("aaa" => "bbb").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/SourceType does not define properties: aaa").to_h
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => attributes.merge("name" => 123).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "OpenAPIParser::ValidateError: #/components/schemas/SourceType/properties/name expected string, but received Integer: 123").to_h
        )
      end
    end
  end

  describe("/api/v1.0/source_types/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = SourceType.create!(attributes)

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s))
        )
      end

      it "failure: with an invalid id" do
        instance = SourceType.create!(attributes)

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>404}]}
        )
      end
    end
  end

  describe("/api/v1.0/source_types/:id/sources") do
    def subcollection_path(id, subcollection)
      File.join(collection_path, id.to_s, subcollection)
    end

    context "get" do
      it "success: with a valid id" do
        instance = SourceType.create!(attributes)

        get(subcollection_path(instance.id, "sources"), :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "failure: with an invalid id" do
        instance = SourceType.create!(attributes)
        missing_id = (instance.id * 1000)
        expect(Source.exists?(missing_id)).to eq(false)

        get(subcollection_path(missing_id, "sources"), :headers => headers)

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>404}]}
        )
      end
    end
  end
end
