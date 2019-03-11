class SwaggerGenerator
  def rails_routes
    Rails.application.routes.routes.each_with_object([]) do |route, array|
      r = ActionDispatch::Routing::RouteWrapper.new(route)
      next if r.internal? # Don't display rails routes
      next if r.engine? # Don't care right now...

      array << r
    end
  end

  def swagger_file
    Pathname.new(__dir__).join("../../public/doc/swagger-2-v0.1.0.yaml").to_s
  end

  def swagger_contents
    @swagger_contents ||= begin
      require 'yaml'
      content = File.read(swagger_file).tap { |c| c.gsub!("- null", "- NULL VALUE") }
      YAML.load(content)
    end
  end

  def initialize
    app_prefix, app_name = base_path.match(/\A(.*)\/(.*)\/v\d+.\d+\z/).captures
    ENV['APP_NAME'] = app_name
    ENV['PATH_PREFIX'] = app_prefix
    Rails.application.reload_routes!
  end

  def base_path
    swagger_contents["basePath"]
  end

  def applicable_rails_routes
    rails_routes.select { |i| i.path.start_with?(base_path) }
  end

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
          when "index"   then swagger_list_description(klass_name, primary_collection)
          when "show"    then swagger_show_description(klass_name)
          when "destroy" then swagger_destroy_description(klass_name)
          when "create"  then swagger_create_description(klass_name)
          when "update"  then swagger_update_description(klass_name, verb)
        end

      unless expected_paths[sub_path][verb]
        # If it's not generic action but a custom method like e.g. `post "order", :to => "service_plans#order"`, we will
        # try to take existing definition, because the description, summary, etc. are likely to be custom.
        expected_paths[sub_path][verb] =
          case verb
          when "post"
            swagger_contents.dig('paths', sub_path, verb) || swagger_create_description(klass_name)
          when "get"
            swagger_contents.dig('paths', sub_path, verb) || swagger_show_description(klass_name)
          else
            swagger_contents.dig('paths', sub_path, verb)
          end
      end
    end
  end

  def definitions
    @definitions ||= {}
  end

  def build_definition(klass_name)
    definitions[klass_name] = swagger_definition(klass_name)
    "#/definitions/#{klass_name}"
  end

  def parameters
    @parameters ||= {}
  end

  def build_parameter(name, value = nil)
    parameters[name] = value
    "#/parameters/#{name}"
  end

  def swagger_list_description(klass_name, primary_collection)
    primary_collection = nil if primary_collection == klass_name
    {
      "summary" => "List #{klass_name.pluralize}#{" for #{primary_collection}" if primary_collection}",
      "operationId" => "list#{primary_collection}#{klass_name.pluralize}",
      "description" => "Returns an array of #{klass_name} objects",
      "parameters" => [
        {"$ref" => "#/parameters/QueryLimit"},
        {"$ref" => "#/parameters/QueryOffset"}
      ],
      "produces" => ["application/json"],
      "responses" => {
        200 => {
          "description" => "#{klass_name.pluralize} collection",
          "schema" => {"$ref" => build_collection_definition(klass_name)}
        }
      }
    }.tap do |h|
      h["parameters"] << {"$ref" => build_parameter("ID")} if primary_collection
    end
  end

  def build_collection_definition(klass_name)
    collection_name = "#{klass_name.pluralize}Collection"
    definitions[collection_name] = {
      "type" => "object",
      "properties" => {
        "meta" => {"$ref" => "#/definitions/CollectionMetadata"},
        "links" => {"$ref" => "#/definitions/CollectionLinks"},
        "data" => {
          "type" => "array",
          "items" => {"$ref" => build_definition(klass_name)}
        }
      }
    }

    "#/definitions/#{collection_name}"
  end

  def swagger_definition(klass_name)
    {
      "type"       => "object",
      "properties" => swagger_definition_properties(klass_name),
    }
  end

  def swagger_definition_properties(klass_name)
    model = klass_name.constantize
    model.columns_hash.map do |key, value|
      unless(GENERATOR_ALLOW_BLACKLISTED_ATTRIBUTES[key.to_sym] || []).include?(klass_name)
        next if GENERATOR_BLACKLIST_ATTRIBUTES.include?(key.to_sym)
      end

      [key, swagger_definition_properties_value(klass_name, model, key, value)]
    end.compact.sort.to_h
  end

  def swagger_definition_properties_value(klass_name, model, key, value)
    if key == model.primary_key
      {
        "$ref" => "#/definitions/ID"
      }
    elsif key.ends_with?("_id")
      properties_value = {}
      if GENERATOR_READ_ONLY_DEFINITIONS.include?(klass_name)
        # Everything under providers data is read only for now
        properties_value["$ref"] = "#/definitions/ID"
      else
        properties_value["$ref"] = swagger_contents.dig("definitions", klass_name, "properties", key, "$ref") || "#/definitions/ID"
      end
      properties_value
    else
      properties_value = {
        "type" => "string"
      }

      case value.sql_type_metadata.type
      when :datetime
        properties_value["format"] = "date-time"
      when :integer
        properties_value["type"] = "integer"
      when :float
        properties_value["type"] = "number"
      when :boolean
        properties_value["type"] = "boolean"
      when :jsonb
        ['type', 'items'].each do |property_key|
          prop = swagger_contents.dig("definitions", klass_name, "properties", key, property_key)
          properties_value[property_key] = prop if prop.present?
        end
      end

      # Take existing attrs, that we won't generate
      ['example', 'format', 'readOnly', 'title', 'description'].each do |property_key|
        property_value                 = swagger_contents.dig("definitions", klass_name, "properties", key, property_key)
        properties_value[property_key] = property_value if property_value
      end

      if GENERATOR_READ_ONLY_DEFINITIONS.include?(klass_name) || GENERATOR_READ_ONLY_ATTRIBUTES.include?(key.to_sym)
        # Everything under providers data is read only for now
        properties_value['readOnly'] = true
      end

      properties_value.sort.to_h
    end
  end

  def swagger_show_description(klass_name)
    {
      "summary" => "Show an existing #{klass_name}",
      "operationId" => "show#{klass_name}",
      "description" => "Returns a #{klass_name} object",
      "produces" => ["application/json"],
      "parameters" => [{"$ref" => build_parameter("ID")}],
      "responses" => {
        200 => {
          "description" => "#{klass_name} info",
          "schema" => {"$ref" => build_definition(klass_name)}
        },
        404 => {"description" => "Not found"}
      }
    }
  end

  def swagger_destroy_description(klass_name)
    {
      "summary" => "Delete an existing #{klass_name}",
      "operationId" => "delete#{klass_name}",
      "description" => "Deletes a #{klass_name} object",
      "produces" => ["application/json"],
      "parameters" => [{"$ref" => build_parameter("ID")}],
      "responses" => {
        204 => {"description" => "#{klass_name} deleted"},
        404 => {"description" => "Not found"}
      }
    }
  end

  def swagger_create_description(klass_name)
    {
      "summary" => "Create a new #{klass_name}",
      "operationId" => "create#{klass_name}",
      "description" => "Creates a #{klass_name} object",
      "produces" => ["application/json"],
      "consumes" => ["application/json"],
      "parameters" => [
        {
          "name" => "body",
          "in" => "body",
          "description" => "#{klass_name} attributes to create",
          "required" => true,
          "schema" => {"$ref" => build_definition(klass_name)}
        }
      ],
      "responses" => {
        201 => {
          "description" => "#{klass_name} creation successful",
          "schema" => {
            "type" => "object",
            "items" => {"$ref" => build_definition(klass_name)}
          }
        }
      }
    }
  end

  def swagger_update_description(klass_name, verb)
    action = verb == "patch" ? "Update" : "Replace"
    {
      "summary" => "#{action} an existing #{klass_name}",
      "operationId" => "#{action.downcase}#{klass_name}",
      "description" => "#{action}s a #{klass_name} object",
      "produces" => ["application/json"],
      "consumes" => ["application/json"],
      "parameters" => [
        {"$ref" => build_parameter("ID")},
        {
          "name" => "body",
          "in" => "body",
          "description" => "#{klass_name} attributes to update",
          "required" => true,
          "schema" => {"$ref" => build_definition(klass_name)}
        }
      ],
      "responses" => {
        204 => {"description" => "Updated, no content"},
        404 => {"description" => "Not found"}
      }
    }
  end

  def run
    parameters["QueryOffset"] = {
      "in" => "query",
      "name" => "offset",
      "type" => "integer",
      "required" => false,
      "default" => 0,
      "minimum" => 0,
      "description" => "The number of items to skip before starting to collect the result set."
    }

    parameters["QueryLimit"] = {
      "in" => "query",
      "name" => "limit",
      "type" => "integer",
      "required" => false,
      "default" => 100,
      "minimum" => 1,
      "maximum" => 1000,
      "description" => "The numbers of items to return per page."
    }

    definitions["CollectionLinks"] = {
      "type" => "object",
      "properties" => {
        "first" => {
          "type" => "string"
        },
        "last"  => {
          "type" => "string"
        },
        "prev"  => {
          "type" => "string"
        },
        "next"  => {
          "type" => "string"
        }
      }
    }

    definitions["CollectionMetadata"] = {
      "type" => "object",
      "properties" => {
        "count" => {
          "type" => "integer"
        }
      }
    }

    definitions["OrderParameters"] = {
      "type" => "object",
      "properties" => {
        "service_parameters" => {
          "type" => "object",
          "description" => "JSON object with provisioning parameters"
        },
        "provider_control_parameters" => {
          "type" => "object",
          "description" => "The provider specific parameters needed to provision this service. This might include namespaces, special keys"
        }
      }
    }

    definitions["Tagging"] = {
      "type"       => "object",
      "properties" => {
        "tag_id" => {"$ref" => "#/definitions/ID"},
        "name"   => {"type" => "string", "readOnly" => true, "example" => "architecture"},
        "value"  => {"type" => "string", "readOnly" => true, "example" => "x86_64"}
      }
    }

    definitions["ID"] = {
      "type"=>"string", "description"=>"ID of the resource", "pattern"=>"/^\\d+$/", "readOnly"=>true
    }

    new_content = swagger_contents
    new_content["paths"] = build_paths.sort.to_h
    new_content["parameters"] = parameters.sort.each_with_object({}) { |(name, val), h| h[name] = val || swagger_contents["parameters"][name] || {} }
    new_content["definitions"] = definitions.sort.each_with_object({}) { |(name, val), h| h[name] = val || swagger_contents["definitions"][name] || {} }
    File.write(swagger_file, new_content.to_yaml(line_width: -1).sub("---\n", "").tap { |c| c.gsub!("- NULL VALUE", "- null") })
  end
end

GENERATOR_BLACKLIST_ATTRIBUTES           = [
  :resource_timestamp, :resource_timestamps, :resource_timestamps_max, :tenant_id
].to_set.freeze
GENERATOR_ALLOW_BLACKLISTED_ATTRIBUTES   = {
  :tenant_id => ['Source', 'Endpoint', 'Authentication'].to_set.freeze
}
GENERATOR_READ_ONLY_DEFINITIONS = [
  'Container', 'ContainerGroup', 'ContainerImage', 'ContainerNode', 'ContainerProject', 'ContainerTemplate', 'Flavor',
  'OrchestrationStack', 'ServiceInstance', 'ServiceOffering', 'ServiceOfferingIcon', 'ServicePlan', 'Tag', 'Tagging',
  'Vm', 'Volume', 'VolumeAttachment', 'VolumeType'
].to_set.freeze
GENERATOR_READ_ONLY_ATTRIBUTES = [
  :created_at, :updated_at, :archived_at, :last_seen_at
].to_set.freeze

namespace :swagger do
  desc "Generate the swagger.yml contents"
  task :generate => :environment do
    SwaggerGenerator.new.run
  end
end
