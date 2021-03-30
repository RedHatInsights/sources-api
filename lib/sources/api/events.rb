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

      def self.raise_event_with_logging_if(raise_event, event, payload, headers = nil)
        return unless raise_event

        with_logging { raise_event(event, payload, headers) }
      end

      def self.raise_event_with_logging(event, payload, headers = nil)
        with_logging { raise_event(event, payload, headers) }
      end

      def self.with_logging(&_block)
        Rails.logger.debug("publishing message to topic \"platform.sources.event-stream\"...")

        yield if block_given?

        Rails.logger.debug("publishing message to topic \"platform.sources.event-stream\"...Complete")
      end
    end
  end
end
