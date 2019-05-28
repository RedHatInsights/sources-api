require "api/graphql"
require "manageiq/api/common/graphql"

module Api
  class GraphqlController < ApplicationController
    def query
      variables = ::ManageIQ::API::Common::GraphQL.ensure_hash(params[:variables])
      result = Api::GraphQL::Schema.execute(
        params[:query],
        :variables => variables
      )
      render :json => result
    end
  end
end
