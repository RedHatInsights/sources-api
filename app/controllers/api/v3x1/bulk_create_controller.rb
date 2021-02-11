module Api
  module V3x1
    class BulkCreateController < ApplicationController
      def create
        # Authorize creating a new source, before we go through the processing.
        authorize(Source.new)
        bulk = Sources::BulkAssembly.new(params_for_create).process

        render :status => 201, :json => bulk.output
      end
    end
  end
end
