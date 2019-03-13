module Api
  module V0
    module Mixins
      module UpdateMixin
        def update
          record = model.update(params.require(:id), params_for_update)
          Sources::Api::Events.raise_event("#{model}.update", record.as_json)
          head :no_content
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end
  end
end
