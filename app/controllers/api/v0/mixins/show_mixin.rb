module Api
  module V0
    module Mixins
      module ShowMixin
        def show
          render json: model.find(params.require(:id))
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end
  end
end
