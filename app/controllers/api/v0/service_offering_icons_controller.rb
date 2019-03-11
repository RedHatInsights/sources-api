module Api
  module V0
    class ServiceOfferingIconsController < ApplicationController
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin

      private

      def model
        ServiceOfferingIcon
      end
    end
  end
end
