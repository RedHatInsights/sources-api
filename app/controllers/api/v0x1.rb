module Api
  module V0x1
    class RootController < ApplicationController
      def openapi
        render :json => Api::Docs["0.1"].to_json
      end
    end

    class AuthenticationsController < Api::V0::AuthenticationsController; end
    class EndpointsController < Api::V0::EndpointsController; end
    class SourcesController < Api::V0::SourcesController; end
    class SourceTypesController < Api::V0::SourceTypesController; end
  end
end
