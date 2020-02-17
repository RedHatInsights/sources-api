module Api
  module V2x0
    class ApplicationAuthenticationsController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin
      include Api::V1::Mixins::UpdateMixin

      def create
        application_authentication = ApplicationAuthentication.create!(params_for_create)
        raise_event("#{model}.create", application_authentication.as_json)
        render :json => application_authentication, :status => :created, :location => instance_link(application_authentication)
      end
    end
  end
end
