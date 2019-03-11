module Api
  module V0
    class ServiceOfferingsController < ApplicationController
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin
    end
  end
end
