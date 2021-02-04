module Api
  module V3x1
    class BulkCreateController < ApplicationController
      def create
        # Authorize creating a new source, before we go through the processing.
        authorize(Source.new)
        params.permit!

        bulk = Sources::BulkAssembly.new(params).process

        render :status => 201, :json => bulk.output
      end
    end
  end
end
