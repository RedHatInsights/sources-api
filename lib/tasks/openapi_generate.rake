require 'manageiq/api/common/open_api/generator'
class OpenapiGenerator < ManageIQ::API::Common::OpenApi::Generator
  def build_paths
    applicable_rails_routes.each_with_object({}) do |route, expected_paths|
      without_format = route.path.split("(.:format)").first
      sub_path = without_format.split(base_path).last.sub(/:[_a-z]*id/, "{id}")
      klass_name = route.controller.split("/").last.camelize.singularize
      verb = route.verb.downcase
      primary_collection = sub_path.split("/")[1].camelize.singularize

      expected_paths[sub_path] ||= {}
      expected_paths[sub_path][verb] =
        case route.action
          when "index"   then openapi_list_description(klass_name, primary_collection)
          when "show"    then openapi_show_description(klass_name)
          when "destroy" then openapi_destroy_description(klass_name)
          when "create"  then openapi_create_description(klass_name)
          when "update"  then openapi_update_description(klass_name, verb)
        end

      unless expected_paths[sub_path][verb]
        # If it's not generic action but a custom method like e.g. `post "order", :to => "service_plans#order"`, we will
        # try to take existing schema, because the description, summary, etc. are likely to be custom.
        expected_paths[sub_path][verb] =
          case verb
          when "post"
            if sub_path == "/graphql" && route.action == "query"
              schemas["GraphQLResponse"] = ::ManageIQ::API::Common::GraphQL.openapi_graphql_response
              ::ManageIQ::API::Common::GraphQL.openapi_graphql_description
            else
              openapi_contents.dig("paths", sub_path, verb) || openapi_create_description(klass_name)
            end
          when "get"
            openapi_contents.dig("paths", sub_path, verb) || openapi_show_description(klass_name)
          else
            openapi_contents.dig("paths", sub_path, verb)
          end
      end
    end
  end

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

GENERATOR_READ_ONLY_DEFINITIONS = [
].to_set.freeze
GENERATOR_READ_ONLY_ATTRIBUTES = [
  :created_at, :updated_at, :archived_at, :last_seen_at
].to_set.freeze

namespace :openapi do
  desc "Generate the openapi.json contents"
  task :generate => :environment do
    OpenapiGenerator.new.run
  end
end
