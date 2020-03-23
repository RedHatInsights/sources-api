module Api
  module V3x0
    class ApplicationsController < Api::V2x0::ApplicationsController
      include Mixins::IndexMixin
    end
  end
end
