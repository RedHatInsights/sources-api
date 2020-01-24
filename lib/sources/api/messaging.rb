module Sources
  module Api
    module Messaging
      def self.client
        require "manageiq-messaging"

        Thread.current[:messaging_client] ||= begin
          ManageIQ::Messaging::Client.open(
            :protocol => :Kafka,
            :host     => ENV["QUEUE_HOST"] || "localhost",
            :port     => ENV["QUEUE_PORT"] || "9092",
            :encoding => "json"
          )
        end
      end

      def self.topics
        # TODO add an interface to ManageIQ::Messaging::Client to get a topic list
        client.send(:kafka_client)&.topics || []
      end
    end
  end
end
