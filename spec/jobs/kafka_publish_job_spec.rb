require 'rails_helper'

RSpec.describe KafkaPublishJob, :type => :job do
  let(:client) { instance_double(ManageIQ::Messaging::Client) }
  before do
    allow(Sources::Api::Messaging).to receive(:client).and_return(client)
    allow(client).to receive(:publish_topic)
  end

  let(:payload) { {:thing => true}.to_json }

  it "publishes the message/event/payload specified" do
    expect(client).to receive(:publish_topic).with(
      :service => "some_topic",
      :event   => "test_event",
      :payload => payload
    )

    KafkaPublishJob.perform_now("some_topic", "test_event", payload)
  end
end
