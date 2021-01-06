require "manageiq-messaging"

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
        :service     => SERVICE_NAME,
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

    payload = JSON.parse(event.payload)
    model_class = payload["resource_type"].classify.constantize
    validate_resource_type(model_class)
    record_id = payload["resource_id"]
    object = model_class.find(record_id)
    options = {
      :availability_status => payload["status"],
      :last_checked_at     => Time.now.utc
    }
    options[:availability_status_error] = payload["error"] if %(Endpoint Application).include?(model_class.name)
    options[:last_available_at] = options[:last_checked_at] if options[:availability_status] == 'available'

    object.update!(options)
    raise_event("#{model_class}.update", object.as_json, event.headers)
  rescue NameError
    Rails.logger.error("Invalid resource_type #{payload["resource_type"]}")
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Could not find #{model_class} with id #{record_id}")
  rescue ActiveRecord::RecordInvalid
    Rails.logger.error("Invalid status #{payload["status"]}")
  rescue => e
    Rails.logger.error(["Something is wrong when processing Kafka message: ", e.message, *e.backtrace].join($RS))
  end

  def raise_event(event, payload, headers)
    Sources::Api::Events.raise_event(event, payload, headers)
  rescue => e
    Rails.logger.error(["Failed to send Kafka message with event type(#{event}): ", e.message, *e.backtrace].join($RS))
  end

  def validate_resource_type(model_class)
    # For security reason only accept explicitly listed models
    raise NameError unless [Application, Endpoint, Source].include?(model_class)
  end

  def default_messaging_options
    {:protocol => :Kafka, :encoding => 'json'}
  end
end
