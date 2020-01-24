require "more_core_extensions/core_ext/module/cache_with_timeout"

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

      cache_with_timeout(:topics) do
        # TODO add an interface to ManageIQ::Messaging::Client to get a topic list
        client.send(:kafka_client)&.topics || []
      end
    end
  end
end
