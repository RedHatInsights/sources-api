class Tenant < ApplicationRecord
  has_many :authentications
  has_many :endpoints
  has_many :sources

  def self.tenancy_enabled?
    ENV["BYPASS_TENANCY"].blank?
  end

  # as_json serialization for internal API's tenants_controller
  # overrides Insights::API::Common::OpenApi::Serializer
  def _schema(arg)
    version = api_version_from_prefix(arg[:prefixes].first)
    if version.to_f < 2.0
      super
    else
      presentation_name = self.class.try(:presentation_name) || self.class.name
      ::Sources::Api::InternalDocs.instance[version].definitions[presentation_name]
    end
  end
end
