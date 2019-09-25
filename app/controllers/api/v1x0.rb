module Api
  module V1x0
    class RootController < ApplicationController
      def openapi
        render :json => ::ManageIQ::API::Common::OpenApi::Docs.instance["1.0"].to_json
      end
    end

    class ApplicationsController < Api::V1::ApplicationsController; end
    class ApplicationTypesController < Api::V1::ApplicationTypesController; end
    class AuthenticationsController < Api::V1::AuthenticationsController; end
    class EndpointsController < Api::V1::EndpointsController; end
    class GraphqlController < Api::V1::GraphqlController; end
    class SourcesController < Api::V1::SourcesController; end
    class SourceTypesController < Api::V1::SourceTypesController; end
  end
end
