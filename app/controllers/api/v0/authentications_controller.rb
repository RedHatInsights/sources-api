module Api
  module V0
    class AuthenticationsController < ApplicationController
      include Api::V0::Mixins::DestroyMixin
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin
      include Api::V0::Mixins::UpdateMixin

      def create
        authentication = model.create!(params_for_create)
        render :json => authentication, :status => :created, :location => instance_link(authentication)
      end
    end
  end
end
