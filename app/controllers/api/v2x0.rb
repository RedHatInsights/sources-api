module Api
  module V2x0
    class RootController < ApplicationController
      def openapi
        render :json => ::Insights::API::Common::OpenApi::Docs.instance["2.0"].to_json
      end
    end

    class ApplicationsController     < Api::V1x0::ApplicationsController; end
    class ApplicationTypesController < Api::V1x0::ApplicationTypesController; end
    class AuthenticationsController  < Api::V1x0::AuthenticationsController; end
    class EndpointsController        < Api::V1x0::EndpointsController; end
    class GraphqlController          < Api::V1x0::GraphqlController; end
    class SourcesController          < Api::V1x0::SourcesController; end
  end
end
