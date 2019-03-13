module Api
  module V0
    class AuthenticationsController < ApplicationController
      include Api::V0::Mixins::DestroyMixin
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin
      include Api::V0::Mixins::UpdateMixin

      def create
        authentication = model.create!(params_for_create)

        event_payload = params_for_create.to_h.merge("id" => authentication.id.to_s).except(*model.encrypted_columns)
        Sources::Api::Events.raise_event("#{model}.create", event_payload)

        render :json => authentication, :status => :created, :location => instance_link(authentication)
      end
    end
  end
end
