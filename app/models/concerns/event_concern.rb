module EventConcern
  extend ActiveSupport::Concern

  included do
    after_destroy :raise_event, :prepend => true
  end

  def raise_event
    headers = Insights::API::Common::Request.current_forwardable
    logger.debug("publishing message to topic \"platform.sources.event-stream\"...")
    Sources::Api::Events.raise_event("#{self.class}.destroy", self.as_json, headers)
    logger.debug("publishing message to topic \"platform.sources.event-stream\"...Complete")
  end
end
