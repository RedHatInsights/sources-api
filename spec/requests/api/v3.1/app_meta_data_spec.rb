RSpec.describe("v3.1 - AppMetaData") do
  include ::Spec::Support::TenantIdentity

  let(:messaging_client) { instance_double("ManageIQ::Messaging::Client") }
  before do
    allow(messaging_client).to receive(:publish_topic)
    allow(Sources::Api::Messaging).to receive(:client).and_return(messaging_client)
  end

  let(:headers)          { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:attributes)       { {"name" => "a_field", "payload" => {"value" => 1234}} }
  let(:collection_path)  { "/api/v3.1/app_meta_data" }

  describe("/api/v3.1/app_meta_data") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        create(:app_meta_data, attributes)

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes)])
        )
      end
    end
  end
end
