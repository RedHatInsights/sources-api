require "manageiq-messaging"

describe Api::V1::Mixins::DestroyMixin do
  describe Api::V1x0::SourcesController, :type => :request do
    include ::Spec::Support::TenantIdentity

    let(:headers) {   {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
    let!(:source_1)   { create(:source, name: "test_source 1") }
    let(:client)      { instance_double("ManageIQ::Messaging::Client") }
    before do
      allow(client).to receive(:publish_topic)
      allow(Sources::Api::Messaging).to receive(:client).and_return(client)
    end

    it "Primary Collection: delete /sources/:id destroys a Source" do
      delete(api_v1x0_source_url(source_1.id), :headers => headers)

      expect(response.status).to eq(204)
      expect(response.parsed_body).to be_empty
    end

    context "Sub-collection:" do
      let!(:endpoint_1) { create(:endpoint, role: "a", source: source_1) }

      it "delete /sources/:id/endpoint/:id fails with 404" do
        delete(api_v1x0_source_endpoints_url(source_1.id) + "/#{endpoint_1.id}", :headers => headers)

        expect(response.status).to eq(404)
      end
    end
  end
end
