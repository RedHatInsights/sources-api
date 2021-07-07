module Api
  module V3x1
    class AuthenticationsController < Api::V3x0::AuthenticationsController
      include Mixins::UpdateMixin
    end
  end
end
