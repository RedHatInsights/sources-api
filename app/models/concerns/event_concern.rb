module EventConcern
  extend ActiveSupport::Concern

  included do
    after_destroy :raise_event_for_destroy, :prepend => true
  end

  IGNORE_RAISE_EVENT_ATTRIBUTES_LIST = %i[availability_status availability_status_error].freeze

  IGNORE_RAISE_EVENT_LIST = {
    "Application"    => IGNORE_RAISE_EVENT_ATTRIBUTES_LIST + %i[_superkey],
    "Authentication" => IGNORE_RAISE_EVENT_ATTRIBUTES_LIST,
    "Endpoint"       => IGNORE_RAISE_EVENT_ATTRIBUTES_LIST
  }.freeze

  def ignore_raise_event_for?(attributes)
    ignore_attribute_list = IGNORE_RAISE_EVENT_LIST[self.class.name]
    return false unless ignore_attribute_list

    (ignore_attribute_list & attributes.map(&:to_sym)).present?
  end

  def raise_event_for_update(attributes, headers = safe_headers)
    condition = ignore_raise_event_for?(attributes)
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
