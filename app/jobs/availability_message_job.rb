class AvailabilityMessageJob < ApplicationJob
  queue_as :availability

  def perform(operation, instance, headers)
    Sidekiq.logger.info("Posting #{operation} to event-stream")

    Sources::Api::Events.raise_event(operation, instance.as_json, headers)
  end
end
