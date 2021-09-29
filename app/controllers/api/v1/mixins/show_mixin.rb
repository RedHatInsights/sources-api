module Api
  module V1
    module Mixins
      module ShowMixin
        def show
          authorize(model.new)

          render json: model.find(params.require(:id))
        end
      end
    end
  end
end
