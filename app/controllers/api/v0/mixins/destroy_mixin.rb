module Api
  module V0
    module Mixins
      module DestroyMixin
        def destroy
          model.destroy(params.require(:id))
          raise_event({"id" => params.fetch(:id).to_s})
          head :no_content
        rescue ActiveRecord::RecordNotFound
          head :not_found
        end
      end
    end
  end
end
