require "manageiq-messaging"
require 'sources/api/clowder_config'

class AvailabilityStatusListener
  SERVICE_NAME = "platform.sources.status".freeze
  GROUP_REF = "sources-api-status-worker".freeze
  EVENT_AVAILABILITY_STATUS = "availability_status".freeze

  attr_accessor :messaging_client_options, :client

  def initialize(messaging_client_options = {})
    self.messaging_client_options = default_messaging_options.merge(messaging_client_options)
  end

  def run
    Thread.new { subscribe_to_availability_status }
  end

  def subscribe_to_availability_status
    Rails.logger.info("Sources API availability_status listener started...")

    ManageIQ::Messaging::Client.open(messaging_client_options) do |client|
      client.subscribe_topic(
        :service     => Sources::Api::ClowderConfig.kafka_topic(SERVICE_NAME),
        :persist_ref => GROUP_REF,
        :max_bytes   => 500_000
      ) do |event|
        process_event(event)
      end
    end
  rescue => e
    Rails.logger.error(["Something is wrong with Kafka client: ", e.message, *e.backtrace].join($RS))
    retry
  end

  private

  def process_event(event)
    Rails.logger.info("Kafka message #{event.message} received with payload: #{event.payload}")
    return unless event.message == EVENT_AVAILABILITY_STATUS

    # make sure we have both psk + xrhid in the headers
    Sources::Api::Request.ensure_psk_and_rhid(event.headers)

    if (missing = missing_headers(event.headers)).any?
      Rails.logger.error("Kafka message #{event.message} missing required header(s) (#{REQUIRED_HEADER_GROUPS.slice(*missing).values.join("|")}), found: [#{event.headers.keys.join(',')}]; returning.")
      return
    end

    # async processing so we can process 5 (or more) at once.
    AvailabilityStatusUpdateJob.perform_later(event.payload, event.headers)
  end

  # hash of "groups" where each value is an array of "one of" headers.
  # each group needs to have at least one header from each group
  REQUIRED_HEADER_GROUPS = {
    :identity => %w[x-rh-identity x-rh-sources-account-number]
  }.freeze

  def missing_headers(headers)
    REQUIRED_HEADER_GROUPS.map do |group, req|
      # we need _at least_ one header from each group.
      group unless (req & headers.keys).any?
    end.compact
  end

  def default_messaging_options
    {:protocol => :Kafka, :encoding => 'json'}
  end
end
