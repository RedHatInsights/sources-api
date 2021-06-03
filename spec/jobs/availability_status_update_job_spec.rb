require 'rails_helper'

RSpec.describe AvailabilityStatusUpdateJob, :type => :job do
  let(:now)     { Time.utc(2020, 1, 1, 12, 30) }
  let(:payload) { {"resource_type" => resource_type, "resource_id" => resource_id, "status" => status, "error" => reason}.to_json }
  let(:headers) { {"SECRET_HEADER" => "PASSWORD", "x-rh-identity" => "ayyyy"} }
  let(:reason)  { "host unreachable" }
  let(:status)  { "unavailable" }

  subject { AvailabilityStatusUpdateJob }

  context "when body contains valid resource_type and id" do
    let(:endpoint) do
      create(:endpoint, :role => "first", :default => true)
    end
    let(:resource_type) { "endpoint" }
    let(:resource_id)   { endpoint.id.to_s }

    before { Timecop.freeze(now) }

    context "when status is available" do
      let(:status) { "available" }

      context "Source" do
        it "updates availability status and last_available_at" do
          expect(Sources::Api::Events).to receive(:raise_event).twice

          subject.perform_now(payload, headers)

          endpoint.reload
          expect(endpoint).to have_attributes(
            :availability_status       => status,
            :availability_status_error => reason,
            :last_available_at         => now,
            :last_checked_at           => now
          )
        end
      end

      context "Application" do
        let(:application) { create(:application) }

        let(:resource_type) { "application" }
        let(:resource_id)   { application.id.to_s }

        it "updates availability status and last_available_at" do
          expect(Sources::Api::Events).to receive(:raise_event).twice

          subject.perform_now(payload, headers)

          application.reload
          expect(application).to have_attributes(
            :availability_status       => status,
            :availability_status_error => reason,
            :last_available_at         => now,
            :last_checked_at           => now
          )
        end
      end
    end

    context "when status is unavailable" do
      it "updates availability status" do
        expect(Sources::Api::Events).to receive(:raise_event).twice

        subject.perform_now(payload, headers)

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
        expect(Sidekiq.logger).to receive(:error).with("Invalid status #{status}")

        subject.perform_now(payload, headers)
      end
    end
  end

  context "when resource_type is invalid" do
    let(:resource_type) { "something" }
    let(:resource_id)   { "1" }

    it "logs invalid resource type" do
      expect(Sidekiq.logger).to receive(:error).with("Invalid resource_type #{resource_type}")

      subject.perform_now(payload, headers)
    end
  end

  context "when resource_id does not exist" do
    let(:resource_type) { "Endpoint" }
    let(:resource_id)   { "1" }

    it "logs record not exist" do
      expect(Sidekiq.logger).to receive(:error).with("Could not find #{resource_type} with id #{resource_id}")

      subject.perform_now(payload, headers)
    end
  end
end
