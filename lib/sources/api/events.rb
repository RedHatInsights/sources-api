module Sources
  module Api
    module Events
      def self.raise_event(event, payload, headers = nil)
        raise_event_for_service("platform.sources.event-stream", event, payload, headers)
      end

      def self.raise_event_for_service(service, event, payload, headers = nil)
        return if ENV['NO_KAFKA']

        publish_opts = {
          :service => service,
          :event   => event,
          :payload => payload
        }

        publish_opts[:headers] = headers if headers

        puts "SOURCES: Raising Event for #{publish_opts} ..."
        messaging_client.publish_topic(publish_opts)
      end

      def self.send_message_for_service(service, event, payload, headers = nil)
        return if ENV['NO_KAFKA']

        publish_opts = {
          :service => service,
          :message => event,
          :payload => payload
        }

        publish_opts[:headers] = headers if headers

        puts "SOURCES: Publishing message #{publish_opts} ..."
        messaging_client.publish_message(publish_opts)
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
