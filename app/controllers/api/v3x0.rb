module Api
  module V3x0
    class RootController < ApplicationController
      def openapi
        render :json => ::Insights::API::Common::OpenApi::Docs.instance["3.0"].to_json
      end
    end
  end
end
