class KafkaPublishJob < ApplicationJob
  queue_as :default

  def perform(topic, event, payload)
    Sidekiq.logger.info("Publishing #{event} to #{topic}...")

    Sources::Api::Messaging.client.publish_topic(
      :service => topic,
      :event   => event,
      :payload => payload
    )
  end
end
