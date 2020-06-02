module Api
  module V1
    module Mixins
      module DestroyMixin
        def destroy
          model.destroy(params.require(:id))
          head :no_content
        end
      end
    end
  end
end
