module Internal
  module V0
    class TenantsController < ::ApplicationController
      def index
        render json: model.where(params_for_list)
      end

      def show
        render json: model.find(params.require(:id)).as_json(:prefixes => [request.path])
      end
    end
  end
end
