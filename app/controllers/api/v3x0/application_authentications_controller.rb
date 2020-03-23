module Api
  module V3x0
    class ApplicationAuthenticationsController < Api::V2x0::ApplicationAuthenticationsController
      include Mixins::IndexMixin
    end
  end
end
