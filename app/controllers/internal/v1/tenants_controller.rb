module Internal
  module V1
    class TenantsController < ::ApplicationController
      def index
        render json: model.where(params_for_list)
      end

      def show
        render json: model.find(params.require(:id))
      end
    end
  end
end
