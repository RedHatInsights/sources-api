module Api
  module V0
    class SourcesController < ApplicationController
      include Api::V0::Mixins::DestroyMixin
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin
      include Api::V0::Mixins::UpdateMixin

      def create
        # TODO does this need a transaction
        tenant_id     = Tenant.find_or_create_by!(:external_tenant => params_for_create.fetch("tenant")).id
        create_params = params_for_create.except("tenant").merge("uid" => SecureRandom.uuid, "tenant_id" => tenant_id)

        source = Source.create!(create_params)

        Sources::Api::Events.raise_event("#{model}.create", source.as_json)

        render :json => source, :status => :created, :location => instance_link(source)
      end
    end
  end
end
