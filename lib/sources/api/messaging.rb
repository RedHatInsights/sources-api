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

      def self.send_superkey_steps(tenant:, source_id:, type:, authentication:, provider:, extra: {})
        type.reload

        # map the payload to a string, since that is what we're sending to AWS every time.
        steps = type.super_key_meta_data.each do |m|
          m.payload = JSON.dump(m.payload)
        end

        payload = {
          :tenant_id         => tenant.external_tenant,
          :source_id         => source_id.to_s,
          :authentication_id => authentication.id.to_s,
          :application_type  => type.name,
          :extra             => extra,
          :provider          => provider,
          :superkey_steps    => steps.as_json
        }

        client.publish_topic(
          :service => "platform.sources.superkey-requests",
          :event   => "create_application",
          :payload => payload
        )
      end
    end
  end
end
