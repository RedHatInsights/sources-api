module EventConcern
  extend ActiveSupport::Concern

  included do
    after_destroy :raise_event_for_destroy, :prepend => true
  end

  def raise_event_for_destroy
    headers = Insights::API::Common::Request.current_forwardable

    Sources::Api::Events.raise_event_with_logging("#{self.class}.destroy", self.as_json, headers)
  end
end
