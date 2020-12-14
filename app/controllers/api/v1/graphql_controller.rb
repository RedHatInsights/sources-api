require "insights/api/common/graphql"

module Api
  module V1
    class GraphqlController < ApplicationController
      class << self
        attr_accessor :limit_and_offset
      end

      def query
        schema_overlay = {
          "^.+$" => {
            "field_resolvers" => {
              "tenant" => <<-RESOLVER
                { obj.tenant.external_tenant }
              RESOLVER
            }
          }
        }
        graphql_api_schema = ::Insights::API::Common::GraphQL::Generator.init_schema(request, schema_overlay)
        variables = ::Insights::API::Common::GraphQL.ensure_hash(params[:variables])
        result = graphql_api_schema.execute(
          params[:query],
          :variables => variables
        )

        # metadata calculations
        meta = {"count" => result["data"] ? result["data"]["sources"].size : 0}
        limit_and_offset = Api::V1::GraphqlController.limit_and_offset || {}
        limit = limit_and_offset['limit']
        offset = limit_and_offset['offset']
        meta["limit"]  = limit  if limit
        meta["offset"] = offset if offset

        # apply limit and offset for results
        if meta["count"] > 0
          result = result["data"]["sources"]
          if offset && offset <= result.size
            result = result[offset..-1]
          elsif offset
            result = []
          end
          result = result[0..limit - 1] if limit
        end

        render :json => {'meta' => meta, 'data' => result}
      ensure
        Api::V1::GraphqlController.limit_and_offset = nil
      end
    end
  end
end

module GraphQL
  module Execution
    class Execute
      class << self
        def begin_query(query, _multiplex)
          unless query.selected_operation.children[0].arguments.empty?
            remove_offset_and_limit(query)
          end

          ExecutionFunctions.resolve_root_selection(query)
        end

        private

        # Remove and save limit/offset for root element inside the query
        def remove_offset_and_limit(query)
          limit_and_offset = {}
          query.selected_operation.children[0].arguments.delete_if do |arg|
            if arg.name == 'offset' || arg.name == 'limit'
              limit_and_offset[arg.name] = arg.value
              true
            else
              false
            end
          end
          Api::V1::GraphqlController.limit_and_offset = limit_and_offset
        end
      end
    end
  end
end
