require "insights/api/common/graphql"

module Api
  module V1
    class GraphqlController < ApplicationController
      class << self
        attr_accessor :limits_and_offsets
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
        meta = calculate_metadata(result) || {}
        apply_limits_and_offsets(result)

        render :json => result.to_h.merge({'meta' => meta})
      ensure
        Api::V1::GraphqlController.limits_and_offsets = {}
      end

      private

      def calculate_metadata(data)
        result = {}

        data.to_h["data"]&.each do |o|
          result[o.first] = o.second.size
        end

        {"count" => result}
      end

      def apply_limits_and_offsets(data)
        result = data.to_h["data"]
        limits_and_offsets = Api::V1::GraphqlController.limits_and_offsets
        return unless limits_and_offsets

        result&.each do |o|
          name = o.first
          args = limits_and_offsets[name]

          result[name] = apply_offset(result[name], args["offset"]) if args["offset"]
          result[name] = apply_limit(result[name], args["limit"]) if args["limit"]
        end
      end

      def apply_offset(data, offset)
        offset <= data.size ? data[offset..-1] : []
      end

      def apply_limit(data, limit)
        data[0..limit - 1]
      end
    end
  end
end

module GraphQL
  module Execution
    class Execute
      class << self
        def begin_query(query, _multiplex)
          remove_offsets_and_limits(query)

          ExecutionFunctions.resolve_root_selection(query)
        end

        private

        # Remove and save limit/offset for root elements inside the query
        def remove_offsets_and_limits(query)
          query.selected_operation.children.each do |subquery|
            process_subquery(subquery) unless subquery.arguments.empty?
          end
        end

        def process_subquery(query)
          name = query.name
          limits_and_offsets = {}

          query.arguments.delete_if do |arg|
            if arg.name == 'offset' || arg.name == 'limit'
              limits_and_offsets[arg.name] = arg.value
              true
            else
              false
            end
          end

          Api::V1::GraphqlController.limits_and_offsets ||= {}
          Api::V1::GraphqlController.limits_and_offsets[name] = limits_and_offsets
        end
      end
    end
  end
end
