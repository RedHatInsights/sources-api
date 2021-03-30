require "manageiq-messaging"

describe Api::V1::Mixins::UpdateMixin do
  include ::Spec::Support::TenantIdentity
  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  describe Api::V1x0::SourcesController, :type => :request do
    let(:client)      { instance_double("ManageIQ::Messaging::Client") }

    before do
      allow(client).to receive(:publish_topic)
      allow(Sources::Api::Messaging).to receive(:client).and_return(client)
    end

    it "patch /sources/:id updates a Source" do
      source = create(:source, :name => "abc")

      expect(Sources::Api::Events).to receive(:raise_event).with("Source.update", anything, anything)

      patch(api_v1x0_source_url(source.id), :params => {:name => "xyz"}.to_json, :headers => headers)

      expect(source.reload.name).to eq("xyz")

      expect(response.status).to eq(204)
      expect(response.parsed_body).to be_empty
    end
  end

  describe Api::V1x0::ApplicationsController, :type => :request do
    %i[availability_status availability_status_error].each do |attribute|
      it "patch /applications/:id updates a Application" do
        application = create(:application)

        expect(Sources::Api::Events).not_to receive(:raise_event)

        patch(api_v1x0_application_url(application.id), :params => {attribute => "available"}.to_json, :headers => headers)

        expect(response.status).to eq(204)
        expect(response.parsed_body).to be_empty
      end
    end
  end
end
