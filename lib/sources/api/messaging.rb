module Sources
  module Api
    module Messaging
      def self.client
        Thread.current[:messaging_client] ||= begin
          require "manageiq-messaging"

          ManageIQ::Messaging::Client.open(
            :protocol => :Kafka,
            :host     => ENV["QUEUE_HOST"] || "localhost",
            :port     => ENV["QUEUE_PORT"] || "9092",
            :encoding => "json"
          )
        end
      end
    end
  end
end
