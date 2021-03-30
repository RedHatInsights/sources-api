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

      def self.send_superkey_create_request(application:, super_key:, provider:, extra: {})
        steps = process_payload(application)

        payload = {
          :tenant_id        => application.tenant.external_tenant,
          :source_id        => application.source_id.to_s,
          :application_id   => application.id.to_s,
          :application_type => application.application_type.name,
          :super_key        => super_key.id.to_s,
          :provider         => provider,
          :extra            => extra,
          :superkey_steps   => steps
        }

        client.publish_topic(
          :service => Sources::Api::ClowderConfig.kafka_topic("platform.sources.superkey-requests"),
          :event   => "create_application",
          :payload => payload,
          :headers => Insights::API::Common::Request.current_forwardable
        )
      end

      def self.send_superkey_destroy_request(application:)
        steps = process_payload(application)

        payload = {
          :tenant_id       => application.tenant.external_tenant,
          :super_key       => application.source.super_key_credential.id.to_s,
          :guid            => application.superkey_data["guid"],
          :provider        => application.superkey_data["provider"],
          :steps_completed => application.superkey_data["steps"],
          :superkey_steps  => steps

        }

        client.publish_topic(
          :service => "platform.sources.superkey-requests",
          :event   => "destroy_application",
          :payload => payload,
          :headers => Insights::API::Common::Request.current_forwardable
        )
      end

      def self.process_payload(application)
        application.application_type.super_key_meta_data.each do |m|
          m.payload = JSON.dump(m.payload)
        end.as_json
      end
    end
  end
end
