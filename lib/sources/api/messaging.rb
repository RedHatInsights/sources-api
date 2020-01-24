module Sources
  module Api
    module Messaging
      def self.client
        require "manageiq-messaging"

        Thread.current[:messaging_client] ||= ManageIQ::Messaging::Client.open(
          :protocol => :Kafka,
          :host     => ENV["QUEUE_HOST"] || "localhost",
          :port     => ENV["QUEUE_PORT"] || "9092",
          :encoding => "json"
        )
      end
    end
  end
end
