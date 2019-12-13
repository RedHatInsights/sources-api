module Internal
  module V1
    class ApplicationTypesController < ::ApplicationController
      def update
        record = model.update(params.require(:id), params_for_update)
        raise_event("#{model}.update", record.as_json)
        head :no_content
      end
    end
  end
end
