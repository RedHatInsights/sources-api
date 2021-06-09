module EventConcern
  extend ActiveSupport::Concern

  included do
    after_destroy :raise_event_for_destroy, :prepend => true

    def bulk_message
      payload = case self.class.to_s
                when "Endpoint", "Application"
                  {
                    :source                      => source,
                    :applications                => source.applications,
                    :endpoints                   => source.endpoints,
                    :authentications             => authentications,
                    :application_authentications => ApplicationAuthentication.where(:authentication => authentications)
                  }
                when "Authentication"
                  source = resource.try(:source) || resource
                  {
                    :source                      => source,
                    :applications                => source.applications,
                    :endpoints                   => source.endpoints,
                    :authentications             => source.authentications,
                    :application_authentications => ApplicationAuthentication.where(:authentication => source.authentications)
                  }
                when "ApplicationAuthentication"
                  {
                    :source                      => application.source,
                    :applications                => application.source.applications,
                    :endpoints                   => application.source.endpoints,
                    :authentications             => application.authentications,
                    :application_authentications => ApplicationAuthentication.where(:authentication => application.authentications)
                  }
                when "Source"
                  {
                    :source                      => self,
                    :applications                => applications,
                    :endpoints                   => endpoints,
                    :authentications             => authentications || [] - super_key_credential,
                    :application_authentications => ApplicationAuthentication.where(:application => applications)
                  }
                end

      payload.transform_values(&:as_json)
    end

    def update_message(attributes)
      # bulk_message with a field updated that includes what changed, e.g.
      # a source id 123 with an updated name
      # { <...rest...>, "updated": {"Source": {"123": ["name"]}} }
      bulk_message.merge!(
        :updated => {
          self.class.to_s => {id => attributes}
        }
      )
    end
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
    Sources::Api::Events.raise_event_with_logging_if(condition, "Records.update", update_message(attributes), headers)
  end

  def raise_event_for_destroy
    Sources::Api::Events.raise_event_with_logging("#{self.class}.destroy", as_json, safe_headers)
  end

  def safe_headers
    return nil unless Sources::Api::Request.current

    Sources::Api::Request.current_forwardable
  end
end
