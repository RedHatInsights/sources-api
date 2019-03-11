module Api
  module V0
    module Mixins
      module UpdateMixin
        def update
          model.update(params.require(:id), params_for_update)
          raise_event __method__, params_for_update.merge("id" => params.fetch(:id).to_s).except(model.try(:encrypted_columns) || [])
          head :no_content
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end
  end
end
