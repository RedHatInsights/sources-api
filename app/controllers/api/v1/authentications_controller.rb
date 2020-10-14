module Api
  module V1
    class AuthenticationsController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin
      include Api::V1::Mixins::UpdateMixin

      def create
        authentication = Authentication.new(params_for_create).tap { |auth| authorize(auth) }
        authentication.save!

        raise_event("#{model}.create", authentication.as_json)
        render :json => authentication, :status => :created, :location => instance_link(authentication)
      end
    end
  end
end
