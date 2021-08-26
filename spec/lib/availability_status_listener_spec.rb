RSpec.describe AvailabilityStatusListener do
  let(:client)     { double(:client) }
  let(:event_type) { AvailabilityStatusListener::EVENT_AVAILABILITY_STATUS }
  let(:payload)    { {:update => true}.to_json }
  let(:headers)    { {"SECRET_HEADER" => "PASSWORD", "x-rh-identity" => "ayyy"} }

  describe "#subscribe_to_availability_status" do
    let(:message) { ManageIQ::Messaging::ReceivedMessage.new(nil, event_type, payload, headers, nil, client) }

    before do
      allow(ManageIQ::Messaging::Client).to receive(:open).with(
        :protocol => :Kafka,
        :encoding => 'json'
      ).and_yield(client)

      allow(client).to receive(:subscribe_topic).with(
        :service     => AvailabilityStatusListener::SERVICE_NAME,
        :persist_ref => AvailabilityStatusListener::GROUP_REF,
        :max_bytes   => 500_000
      ).and_yield(message)
    end

    context "with the availability_status event_type" do
      it "enqueues the AvailabilityStatusUpdateJob" do
        expect(AvailabilityStatusUpdateJob).to receive(:perform_later).with(payload, headers).once
        expect(Sources::Api::Request).to receive(:ensure_psk_and_rhid).once

        subject.subscribe_to_availability_status
      end
    end

    context "with the wrong event_type" do
      let(:event_type) { "not right" }

      it "does not enqueue the AvailabilityStatusUpdateJob" do
        expect(AvailabilityStatusUpdateJob).not_to receive(:perform_later)

        subject.subscribe_to_availability_status
      end
    end

    context "when the x-rh-identity header is missing" do
      let(:headers) { {"SECRET_HEADER" => "PASSWORD"} }
      let(:endpoint) { create(:endpoint, :role => "first", :default => true) }
      let(:resource_type) { "endpoint" }
      let(:resource_id)   { endpoint.id.to_s }

      it "logs missing header" do
        expect(Rails.logger).to receive(:error).with("Kafka message availability_status missing required header(s) (x-rh-identity|x-rh-sources-account-number), found: [SECRET_HEADER]; returning.")

        subject.subscribe_to_availability_status
      end
    end

    context "with x-rh-sources-account-number" do
      let(:headers) { {"SECRET_HEADER" => "PASSWORD", "x-rh-sources-account-number" => "1234"} }
      let(:endpoint) { create(:endpoint, :role => "first", :default => true) }
      let(:resource_type) { "endpoint" }
      let(:resource_id)   { endpoint.id.to_s }
      let(:xrhid) do
        Base64.strict_encode64(
          JSON.dump(:identity => {
                      :account_number => "1234",
                      :user           => {:is_org_admin => true}
                    })
        )
      end

      it "enqueues the avialability status update job with both x-rh-id + x-rh-sources-account_number" do
        expect(AvailabilityStatusUpdateJob).to receive(:perform_later).with(payload, headers.merge!("x-rh-identity" => xrhid)).once

        subject.subscribe_to_availability_status
      end
    end
  end
end
