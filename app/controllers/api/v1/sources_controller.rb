module Api
  module V1
    class SourcesController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin
      include Api::V1::Mixins::UpdateMixin

      def create
        source_data = params_for_create
        source_data["uid"] = SecureRandom.uuid if source_data["uid"].nil?
        source = Source.create!(source_data)

        raise_event("#{model}.create", source.as_json)

        render :json => source, :status => :created, :location => instance_link(source)
      end

      def check_availability
        source = Source.find(params[:source_id])

        Sources::Api::Messaging.client.publish_topic(
          :service => "platform.topological-inventory.operations-#{source.source_type.name}",
          :event   => "Source.availability_check",
          :payload => {
            :params => {
              :source_id       => source.id.to_s,
              :external_tenant => source.tenant.external_tenant
            }
          }
        )

        render :json => {}, :status => :accepted
      end
    end
  end
end
