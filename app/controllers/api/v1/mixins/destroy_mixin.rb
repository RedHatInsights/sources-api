module Api
  module V1
    module Mixins
      module DestroyMixin
        def destroy
          record = model.destroy(params.require(:id))
          raise_event("#{model}.destroy", record.as_json)
          head :no_content
        end
      end
    end
  end
end
