require 'sources/api/clowder_config'

module Sources
  module Api
    module Events
      def self.raise_event(event, payload, headers = nil)
        return if ENV['NO_KAFKA']

        publish_opts = {
          :service => Sources::Api::ClowderConfig.kafka_topic("platform.sources.event-stream"),
          :event   => event,
          :payload => payload
        }

        publish_opts[:headers] = headers if headers

        Messaging.client.publish_topic(publish_opts)
      end
    end
  end
end
