module Api
  module V3x0
    class AvailabilitiesController < Api::V2x0::AvailabilitiesController
      include Mixins::IndexMixin
    end
  end
end
