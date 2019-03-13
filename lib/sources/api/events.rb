module Sources
  module Api
    class Events
      class << self
        def raise_event(event, payload)
          messaging_client.publish_topic(
            :service => "platform.sources.event-stream",
            :event   => event,
            :payload => payload
          )
        end

        private

        def messaging_client
          require "manageiq-messaging"

          ManageIQ::Messaging::Client.open({
            :protocol => :Kafka,
            :host     => ENV["QUEUE_HOST"] || "localhost",
            :port     => ENV["QUEUE_PORT"] || "9092",
            :encoding => "json"
          })
        end
      end
    end
  end
end
