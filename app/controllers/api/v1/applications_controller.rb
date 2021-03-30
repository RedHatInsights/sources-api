module Api
  module V1
    class ApplicationsController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin

      def create
        application = Application.new(params_for_create).tap { |app| authorize(app) }
        application.save!

        # we do not want to raise the create event since the application has
        # not been processed by the superkey worker.
        raise_event_if(!application.source.super_key?, "Application.create", application.as_json)

        render :json => application, :status => 201, :location => instance_link(application)
      end

      def update
        application = Application.find(params.require(:id))
        authorize(application)

        application.update!(params_for_update)

        # Here we're raising the create event after the worker has filled in the
        # values for the source, but only the first time after the worker processes the message,
        # from there on we raise the normal update.
        first_time_superkey = (application.source.super_key? && params.try(:[], "extra")&.key?("_superkey"))
        raise_event_if(first_time_superkey, "Application.create", application.as_json)
        raise_event_if(first_time_superkey, "Records.create", application.bulk_message)

        # appending the extra keys in case of _superkey being updated.
        application.raise_event_for_update(params_for_update.keys + params.fetch("extra", {}).keys)

        head :no_content
      end
    end
  end
end
