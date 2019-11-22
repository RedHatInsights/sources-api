require 'insights/api/common/open_api/generator'
class OpenapiGenerator < Insights::API::Common::OpenApi::Generator
  def generator_blacklist_allowed_attributes
    @generator_blacklist_allowed_attributes ||= {
      :tenant_id => ['Authentication', 'Application', 'Endpoint', 'Source'].to_set.freeze
    }
  end

  def generator_blacklist_substitute_attributes
    @generator_blacklist_substitute_attributes ||= {
      :tenant_id => ["tenant", { "type" => "string", "readOnly" => true }].freeze
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

  def handle_custom_route_action(route_action, verb, primary_collection)
    case [primary_collection, verb, route_action]
    when ["Source", "post", "CheckAvailability"]
      {
        "summary"     => "Checks Availability of a Source",
        "operationId" => "checkAvailabilitySource",
        "description" => "Checks Availability of a Source",
        "parameters"  => [
          {
            "$ref" => "#/components/parameters/ID"
          }
        ],
        "responses"   => {
          "202" => {
            "description" => "Availability Check Accepted",
            "content"     => {
              "application/json" => {
                "schema" => {
                  "$ref" => "#/components/schemas/Source"
                }
              }
            }
          },
          "404": {
            "description": "Not found",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/ErrorNotFound"
                }
              }
            }
          }
        }
      }
    end
  end
end

namespace :openapi do
  desc "Generate the openapi.json contents"
  task :generate => :environment do
    OpenapiGenerator.new.run
  end
end
