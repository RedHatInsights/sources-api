module Api
  module V3x0
    class AuthenticationsController < Api::V2x0::AuthenticationsController
      include Mixins::IndexMixin
    end
  end
end
