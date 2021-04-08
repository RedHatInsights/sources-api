module EventConcern
  extend ActiveSupport::Concern

  included do
    after_destroy :raise_event_for_destroy, :prepend => true
  end

  IGNORE_RAISE_EVENT_ATTRIBUTES_LIST = %i[availability_status availability_status_error].freeze

  # TODO: IGNORE_RAISE_EVENT_ATTRIBUTES_LIST will be added later
  IGNORE_RAISE_EVENT_LIST = {
    "Application"    => %i[_superkey],
    "Authentication" => [],
    "Endpoint"       => []
  }.freeze

  def raise_event_allowed?(attributes)
    ignore_attribute_list = IGNORE_RAISE_EVENT_LIST[self.class.name]
    return true unless ignore_attribute_list

    (ignore_attribute_list & attributes.map(&:to_sym)).empty?
  end

  def raise_event_for_update(attributes, headers = safe_headers)
    condition = raise_event_allowed?(attributes)
    Sources::Api::Events.raise_event_with_logging_if(condition, "#{self.class}.update", as_json, headers)
  end

  def raise_event_for_destroy
    Sources::Api::Events.raise_event_with_logging("#{self.class}.destroy", as_json, safe_headers)
  end

  def safe_headers
    return nil unless Insights::API::Common::Request.current

    Insights::API::Common::Request.current_forwardable
  end
end
