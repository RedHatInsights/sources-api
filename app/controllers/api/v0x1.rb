module Api
  module V0x1
    class RootController < ApplicationController
      def openapi
        render :json => Api::Docs["0.1"].to_json
      end
    end

    class AuthenticationsController < Api::V0x0::AuthenticationsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class AvailabilitiesController < Api::V0::AvailabilitiesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class EndpointsController < Api::V0x0::EndpointsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class SourcesController < Api::V0x0::SourcesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class SourceTypesController < Api::V0x0::SourceTypesController
      include Api::V0x1::Mixins::IndexMixin
    end
  end
end
