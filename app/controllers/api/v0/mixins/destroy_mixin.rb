module Api
  module V0
    module Mixins
      module DestroyMixin
        def destroy
          record = model.destroy(params.require(:id))
          Sources::Api::Events.raise_event("#{model}.destroy", record.as_json)
          head :no_content
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end
  end
end
