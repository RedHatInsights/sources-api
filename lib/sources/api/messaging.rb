require "more_core_extensions/core_ext/module/cache_with_timeout"

module Sources
  module Api
    module Messaging
      def self.client
        require "manageiq-messaging"

        @client ||= ManageIQ::Messaging::Client.open(
          :protocol => :Kafka,
          :host     => ENV["QUEUE_HOST"] || "localhost",
          :port     => ENV["QUEUE_PORT"] || "9092",
          :encoding => "json"
        )
      end

      cache_with_timeout(:topics) do
        client.topics || []
      end
    end
  end
end
