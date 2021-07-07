module Api
  module V3x1
    module Mixins
      module UpdateMixin
        include Mixins::PausableMixin

        def update
          record = model.find(params.require(:id))
          authorize(record)

          update_pausable(record) do |allowed_parameters_for_update|
            record.update!(allowed_parameters_for_update)
            record.raise_event_for_update(allowed_parameters_for_update.keys)
          end
        end
      end
    end
  end
end
