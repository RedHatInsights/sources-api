module Api
  module V3x1
    class BulkCreateController < ApplicationController
      def create
        render :status => 201, :json => {}
      end
    end
  end
end
