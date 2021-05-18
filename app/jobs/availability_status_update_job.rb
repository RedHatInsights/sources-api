class AvailabilityStatusUpdateJob < ApplicationJob
  queue_as :availability

  def perform(event, headers)
    payload = JSON.parse(event)
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

    object.raise_event_for_update(options.keys, headers)
  rescue NameError
    Sidekiq.logger.error("Invalid resource_type #{payload["resource_type"]}")
  rescue ActiveRecord::RecordNotFound
    Sidekiq.logger.error("Could not find #{model_class} with id #{record_id}")
  rescue ActiveRecord::RecordInvalid
    Sidekiq.logger.error("Invalid status #{payload["status"]}")
  rescue => e
    Sidekiq.logger.error(["Something is wrong when processing Kafka message: ", e.message, *e.backtrace].join($RS))
  end

  def validate_resource_type(model_class)
    # For security reason only accept explicitly listed models
    raise NameError unless [Application, Endpoint, Source].include?(model_class)
  end
end
