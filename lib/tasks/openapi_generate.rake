require 'insights/api/common/open_api/generator'
class OpenapiGenerator < Insights::API::Common::OpenApi::Generator
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
            "description" => "Availability Check Accepted"
          },
          "404" => {
            "description" => "Not found",
            "content"     => {
              "application/json" => {
                "schema" => {
                  "$ref" => "#/components/schemas/ErrorNotFound"
                }
              }
            }
          }
        }
      }
    end
  end

  # TODO: make readOnly authtype only for update
  # def schema_overrides
  #   authentication = schemas['Authentication']
  #   authentication['properties']['authtype']['readOnly'] = true
  #   super.merge('Authentication' => authentication)
  # end
end

namespace :openapi do
  desc "Generate the openapi.json contents"
  task :generate => :environment do
    OpenapiGenerator.new.run
  end
end
