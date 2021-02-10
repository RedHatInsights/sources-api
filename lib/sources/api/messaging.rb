require "sources/api/clowder_config"

module Sources
  module Api
    module Messaging
      def self.client
        require "manageiq-messaging"

        @client ||= ManageIQ::Messaging::Client.open(
          :protocol => :Kafka,
          :host     => Sources::Api::ClowderConfig.instance['kafkaHost'],
          :port     => Sources::Api::ClowderConfig.instance['kafkaPort'],
          :encoding => "json"
        )
      end

      def self.send_superkey_steps(tenant:, type:, authentication:, provider:, extra: {})
        type.reload

        # map the payload to a string, since that is what we're sending to AWS every time.
        steps = type.super_key_meta_data.each do |m|
          m.payload = JSON.dump(m.payload)
        end

        payload = {
          :tenant_id         => tenant.external_tenant,
          :application_type  => type.name,
          :authentication_id => authentication.id.to_s,
          :provider          => provider,
          :extra             => extra,
          :superkey_steps    => steps.as_json
        }

        client.publish_topic(
          :service => Sources::Api::ClowderConfig.kafka_topic("platform.sources.superkey-requests"),
          :event   => "create_application",
          :payload => payload
        )
      end
    end
  end
end
