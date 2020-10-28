module Api
  module V1
    module Mixins
      module DestroyMixin
        def destroy
          record = model.find(params.require(:id))
          authorize(record)

          record.destroy
          head :no_content
        end
      end
    end
  end
end
