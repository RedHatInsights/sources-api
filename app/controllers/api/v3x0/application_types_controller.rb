module Api
  module V3x0
    class ApplicationTypesController < Api::V2x0::ApplicationTypesController
      include Mixins::IndexMixin
    end
  end
end
