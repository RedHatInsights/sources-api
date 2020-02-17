RSpec.describe("v2.0 - ApplicationAuthentications") do
  include ::Spec::Support::TenantIdentity

  let(:headers)          { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:source_type)      { SourceType.create!(:name => "my-source-type", :product_name => "My Source Type", :vendor => "ACME") }
  let(:source)           { Source.create!(:source_type => source_type, :tenant => tenant, :uid => SecureRandom.uuid, :name => "my-source") }
  let(:application_type) { ApplicationType.create!(:name => "my-app") }
  let(:endpoint)         { Endpoint.create!(:source => source, :tenant => tenant) }
  let(:authentication)   { Authentication.create!(:tenant => tenant, :resource => endpoint) }
  let(:application)      { Application.create!(:application_type => application_type, :source => source, :tenant => tenant) }
  let(:attributes)       { {"application_id" => application.id.to_s, "authentication_id" => authentication.id.to_s } }
  let(:collection_path)  { "/api/v2.0/application_authentications" }

  describe("/api/v2.0/application_authentication") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        ApplicationAuthentication.create!(attributes.merge(:tenant => tenant))

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes)])
        )
      end
    end
  end

  describe("/api/v2.0/application_types/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = ApplicationAuthentication.create!(attributes.merge(:tenant => tenant))

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s))
        )
      end

      it "failure: with an invalid id" do
        instance = ApplicationAuthentication.create!(attributes.merge(:tenant => tenant))

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors" => [{"detail" => "Record not found", "status" => 404}]}
        )
      end
    end
  end
end
