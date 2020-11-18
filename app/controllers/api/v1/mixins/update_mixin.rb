module Api
  module V1
    module Mixins
      module UpdateMixin
        def update
          record = model.find(params.require(:id))
          authorize(record)

          record.update!(params_for_update)
          raise_event("#{model}.update", record.as_json)
          head :no_content
        end
      end
    end
  end
end
