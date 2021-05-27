module Api
  module V3x1
    class RootController < ApplicationController
      def openapi
        render :json => ::Insights::API::Common::OpenApi::Docs.instance["3.1"].to_json
      end
    end

    class ApplicationTypesController < Api::V3x0::ApplicationTypesController; end
    class ApplicationAuthenticationsController < Api::V3x0::ApplicationAuthenticationsController; end
    class AuthenticationsController  < Api::V3x0::AuthenticationsController; end
    class EndpointsController        < Api::V3x0::EndpointsController; end
    class GraphqlController          < Api::V3x0::GraphqlController; end
    class SourceTypesController      < Api::V3x0::SourceTypesController; end
  end
end
