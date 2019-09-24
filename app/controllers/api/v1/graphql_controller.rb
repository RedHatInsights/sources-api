require "manageiq/api/common/graphql"

module Api
  module V1
    class GraphqlController < ApplicationController
      skip_before_action :validate_request

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
        graphql_api_schema = ::ManageIQ::API::Common::GraphQL::Generator.init_schema(request, schema_overlay)
        variables = ::ManageIQ::API::Common::GraphQL.ensure_hash(params[:variables])
        result = graphql_api_schema.execute(
          params[:query],
          :variables => variables
        )
        render :json => result
      end
    end
  end
end
