require 'manageiq/api/common/open_api/generator'
class OpenapiGenerator < ManageIQ::API::Common::OpenApi::Generator
  def generator_blacklist_allowed_attributes
    @generator_blacklist_allowed_attributes ||= {
      :tenant_id => ['Source', 'Endpoint', 'Authentication'].to_set.freeze
    }
  end

  def generator_blacklist_substitute_attributes
    @generator_blacklist_substitute_attributes ||= {
      :tenant_id => ["tenant", { "type" => "string" }].freeze
    }
  end

  def schemas
    @schemas ||= begin
      super.merge(
        "Tenant" => {
          "type"       => "object",
          "properties" => {
            "name"            => {"type" => "string", "readOnly" => true, "example" => "Sample Tenant"},
            "description"     => {"type" => "string", "readOnly" => true, "example" => "Description of the Tenant"},
            "external_tenant" => {"type" => "string", "readOnly" => true, "example" => "External tenant identifier"}
          }
        }
      )
    end
  end
end

namespace :openapi do
  desc "Generate the openapi.json contents"
  task :generate => :environment do
    OpenapiGenerator.new.run
  end
end
