module Api
  module V1
    module Mixins
      module UpdateMixin
        def update
          record = model.find(params.require(:id))
          authorize(record)

          record.update!(params_for_update)

          ignore_raise_event = record.try(:ignore_raise_event_for?, params_for_update.keys)
          raise_event_if(ignore_raise_event, "#{model}.update", record.to_json)

          head :no_content
        end
      end
    end
  end
end
