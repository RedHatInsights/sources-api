module Api
  module V1
    module Mixins
      module UpdateMixin
        def update
          record = model.find(params.require(:id))
          authorize(record)

          record.update!(params_for_update)
          record.raise_event_for_update(params_for_update.keys)

          head :no_content
        end
      end
    end
  end
end
