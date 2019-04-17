module Api
  module V1
    module Mixins
      module UpdateMixin
        def update
          record = model.update(params.require(:id), params_for_update)
          Sources::Api::Events.raise_event("#{model}.update", record.as_json)
          head :no_content
        end
      end
    end
  end
end
