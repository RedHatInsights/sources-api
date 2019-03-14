module Sources
  module Api
    module Events
      def self.raise_event(event, payload)
        messaging_client.publish_topic(
          :service => "platform.sources.event-stream",
          :event   => event,
          :payload => payload
        )
      end

      private_class_method def self.messaging_client
        require "manageiq-messaging"

        @messaging_client ||= ManageIQ::Messaging::Client.open(
          :protocol => :Kafka,
          :host     => ENV["QUEUE_HOST"] || "localhost",
          :port     => ENV["QUEUE_PORT"] || "9092",
          :encoding => "json"
        )
      end
    end
  end
end
