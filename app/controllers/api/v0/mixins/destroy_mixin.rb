module Api
  module V0
    module Mixins
      module DestroyMixin
        def destroy
          record = model.destroy(params.require(:id))
          Sources::Api::Events.raise_event("#{model}.destroy", record.as_json)
          head :no_content
        end
      end
    end
  end
end
