module Api
  module V3x1
    class BulkCreateController < ApplicationController
      def create
        # Authorize creating a new source, before we go through the processing.
        authorize(Source.new)
        params.permit!

        output = Sources::Api::BulkAssembly.bulk_create(
          :sources         => params[:sources],
          :endpoints       => params[:endpoints],
          :applications    => params[:applications],
          :authentications => params[:authentications]
        )

        render :status => 201, :json => output
      end
    end
  end
end
