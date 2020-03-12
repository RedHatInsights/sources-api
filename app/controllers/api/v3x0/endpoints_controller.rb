module Api
  module V3x0
    class EndpointsController < Api::V2x0::EndpointsController
      include Mixins::IndexMixin
    end
  end
end
