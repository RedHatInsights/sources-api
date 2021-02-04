module Api
  module V3x1
    class SuperKeyController < ApplicationController
      def create
        # Authorize for source creation before running request
        authorize(Source.new)
        Sources::SuperKey.new(superkey_params).create

        render :status => 202, :json => {}
      end

      def destroy
        # Authorize for source deletion before running request
        authorize(Source.new)
        Sources::SuperKey.new(params.permit(:id)).teardown

        render :status => 202, :json => {}
      end

      private

      def superkey_params
        params.permit(:provider, :applications, :source_id)
      end
    end
  end
end
