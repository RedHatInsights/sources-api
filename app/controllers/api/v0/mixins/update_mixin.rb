module Api
  module V0
    module Mixins
      module UpdateMixin
        def update
          model.update(params.require(:id), params_for_update)
          head :no_content
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end
  end
end
