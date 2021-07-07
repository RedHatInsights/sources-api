module Api
  module V3x1
    class EndpointsController < Api::V3x0::EndpointsController
      include Mixins::UpdateMixin
    end
  end
end
