RSpec.describe AvailabilityStatusListener do
  let(:client)     { double(:client) }
  let(:event_type) { AvailabilityStatusListener::EVENT_AVAILABILITY_STATUS }
  let(:payload)    { {"resource_type" => resource_type, "resource_id" => resource_id, "status" => status, "error" => reason}.to_json }
  let(:status)     { "unavailable" }
  let(:reason)     { "host unreachable" }
  let(:now)        { Time.new(2020).utc }

  describe "#subscribe_to_availability_status" do
    let(:message) { ManageIQ::Messaging::ReceivedMessage.new(nil, event_type, payload, {}, nil, client) }

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

    context "when body contains valid resource_type and id" do
      let(:endpoint) do
        create(:endpoint, :role => "first", :default => true)
      end
      let(:resource_type) { "endpoint" }
      let(:resource_id)   { endpoint.id.to_s }

      before { allow(Time).to receive(:now).and_return(now) }

      context "when status is available" do
        let(:status) { "available" }

        it "updates availability status and last_available_at" do
          expect(Sources::Api::Events).to receive(:raise_event).with("Endpoint.update", anything)

          subject.subscribe_to_availability_status

          endpoint.reload
          expect(endpoint).to have_attributes(
            :availability_status       => status,
            :availability_status_error => reason,
            :last_available_at         => now,
            :last_checked_at           => now
          )
        end
      end

      context "when status is unavailable" do
        it "updates availability status" do
          expect(Sources::Api::Events).to receive(:raise_event).with("Endpoint.update", anything)

          subject.subscribe_to_availability_status

          endpoint.reload
          expect(endpoint).to have_attributes(
            :availability_status       => status,
            :availability_status_error => reason,
            :last_available_at         => nil,
            :last_checked_at           => now
          )
        end
      end

      context "when status is invalid" do
        let(:status) { "wrong status" }

        it "logs invalid status" do
          expect(Rails.logger).to receive(:error).with("Invalid status #{status}")

          subject.subscribe_to_availability_status
        end
      end
    end

    context "when resource_type is invalid" do
      let(:resource_type) { "something" }
      let(:resource_id)   { "1" }

      it "logs invalid resource type" do
        expect(Rails.logger).to receive(:error).with("Invalid resource_type #{resource_type}")

        subject.subscribe_to_availability_status
      end
    end

    context "when resource_id does not exist" do
      let(:resource_type) { "Endpoint" }
      let(:resource_id)   { "1" }

      it "logs record not exist" do
        expect(Rails.logger).to receive(:error).with("Could not find #{resource_type} with id #{resource_id}")

        subject.subscribe_to_availability_status
      end
    end
  end
end
