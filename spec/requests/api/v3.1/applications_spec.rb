RSpec.describe("v3.1 - Applications") do
  include ::Spec::Support::TenantIdentity

  let(:client) { instance_double("ManageIQ::Messaging::Client") }
  before do
    allow(client).to receive(:publish_topic)
    allow(Sources::Api::Messaging).to receive(:client).and_return(client)
  end

  let(:headers)          { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:collection_path)  { "/api/v3.1/applications" }
  let(:source)           { create(:source, :tenant => tenant) }
  let(:application_type) { create(:application_type) }
  let(:payload) do
    {
      "source_id"           => source.id.to_s,
      "application_type_id" => application_type.id.to_s
    }
  end

  describe("/api/v3.1/applications") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        create(:application, payload.merge(:tenant => tenant))

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(1, [a_hash_including(payload)])
        )
      end
    end

    context "post" do
      it "success: with valid body" do
        post(collection_path, :params => payload.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v3.1/applications/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(payload)
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => payload.merge("aaa" => "bbb").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/Application does not define properties: aaa").to_h
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => payload.merge("availability_status" => 123).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::ValidateError: #/components/schemas/Application/properties/availability_status expected string, but received Integer: 123").to_h
        )
      end
    end
  end

  describe("/api/v3.1/applications/:id") do
    context "get" do
      it "success: with a valid id" do
        instance = create(:application, payload.merge(:tenant => tenant))

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => a_hash_including("id" => instance.id.to_s, "tenant" => tenant.external_tenant)
        )
      end

      it "failure: with an invalid id" do
        instance = create(:application, payload.merge(:tenant => tenant))

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors"=>[{"detail" => "Record not found", "status" => "404"}]}
        )
      end
    end

    context "patch" do
      let(:instance) { create(:application, payload.merge(:tenant => tenant)) }
      it "success: with a valid id" do
        new_attributes = {"availability_status" => "available"}
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
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/Application does not define properties: aaa").to_h
        )
      end

      it "failure: with an invalid id" do
        new_attributes = {"availability_status" => "available"}

        patch(instance_path(instance.id * 1000), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors" => [{"detail" => "Record not found", "status" => "404"}]}
        )
      end
    end

    context "delete" do
      it "success: with a valid id" do
        instance = create(:application, payload.merge(:tenant => tenant))

        expect(Sources::Api::Events).to receive(:raise_event).once
        delete(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 204,
          :parsed_body => ""
        )
      end
    end
  end

  describe("/api/v3.1/applications/:id/authentications") do
    def subcollection_path(id, subcollection)
      File.join(collection_path, id.to_s, subcollection)
    end

    context "get" do
      it "success: with a valid id" do
        instance = create(:application, payload.merge(:tenant => tenant))

        get(subcollection_path(instance.id, "authentications"), :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "failure: with an invalid id" do
        instance = create(:application, payload.merge(:tenant => tenant))
        missing_id = (instance.id * 1000)
        expect(Application.exists?(missing_id)).to eq(false)

        get(subcollection_path(missing_id, "authentications"), :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors"=>[{"detail" => "Record not found", "status" => "404"}]}
        )
      end
    end
  end

  describe "superkey" do
    describe "when creating an application attached to a superkey source" do
      let(:src) { create(:source, :app_creation_workflow => "account_authorization") }

      it "does not post the message on create" do
        expect(Sources::Api::Events).not_to receive(:raise_event).with("Application.create", any_args)
        post(collection_path, :params => {:application_type_id => 5, :source_id => src.id}, :headers => headers)
      end
    end

    describe "when updating the application with logic" do
      let(:src) { create(:source, :app_creation_workflow => "account_authorization") }
      let(:instance) { create(:application, :source => src, :superkey_data => {"headers" => original_headers}) }
      let(:original_headers) { {"thing" => true} }
      let(:extra_attributes) { {:extra => {:_superkey => {"worked" => true}}} }

      it "raises the create event instead of the update event" do
        expect(Sources::Api::Events).to receive(:raise_event).with("Application.create", any_args, original_headers).exactly(1).times
        expect(Sources::Api::Events).not_to receive(:raise_event).with("Application.update", any_args)

        patch(instance_path(instance.id), :params => extra_attributes.to_json, :headers => headers)
      end
    end
  end

  def instance_path(id)
    File.join(collection_path, id.to_s)
  end
end
