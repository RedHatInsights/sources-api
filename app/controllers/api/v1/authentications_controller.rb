module Api
  module V1
    class AuthenticationsController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin
      include Api::V1::Mixins::UpdateMixin

      def create
        tenant_id     = Tenant.find_or_create_by!(:external_tenant => params_for_create.fetch("tenant")).id
        create_params = params_for_create.except("tenant").merge("tenant_id" => tenant_id)

        authentication = model.create!(create_params)

        Sources::Api::Events.raise_event("#{model}.create", authentication.as_json)

        render :json => authentication, :status => :created, :location => instance_link(authentication)
      end
    end
  end
end
