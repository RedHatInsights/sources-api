class AvailabilityMessageJob < ApplicationJob
  queue_as :availability

  def perform(operation, instance_json, headers)
    Sidekiq.logger.info("Posting #{operation} to event-stream")

    Sources::Api::Events.raise_event(operation, instance_json, headers)
  end
end
