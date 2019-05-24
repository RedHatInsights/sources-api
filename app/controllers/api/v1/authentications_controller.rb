module Api
  module V1
    class AuthenticationsController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin
      include Api::V1::Mixins::UpdateMixin

      def create
        authentication = model.create!(params_for_create)
        raise_event("#{model}.create", authentication.as_json)
        render :json => authentication, :status => :created, :location => instance_link(authentication)
      end
    end
  end
end
