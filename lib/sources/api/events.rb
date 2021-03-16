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

      def self.raise_event_if(condition, event, payload, headers = nil)
        raise_event(event, payload, headers) unless condition
      end

      def self.raise_event_with_logging(event, payload, headers)
        Rails.logger.debug("publishing message to topic \"platform.sources.event-stream\"...")

        raise_event(event, payload, headers)

        Rails.logger.debug("publishing message to topic \"platform.sources.event-stream\"...Complete")
      end
    end
  end
end
