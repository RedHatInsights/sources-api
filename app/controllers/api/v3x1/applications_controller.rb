module Api
  module V3x1
    class ApplicationsController < Api::V3x0::ApplicationsController
      include Mixins::PausableMixin

      def pause
        app = Application.find(params.require(:application_id)).tap { |s| authorize(s) }
        app.discard!
        AvailabilityMessageJob.perform_later("Application.pause", app.to_json, Sources::Api::Request.current_forwardable)

        head 204
      end

      def unpause
        app = Application.find(params.require(:application_id)).tap { |s| authorize(s) }
        app.undiscard!
        AvailabilityMessageJob.perform_later("Application.unpause", app.to_json, Sources::Api::Request.current_forwardable)

        head 202
      end

      def update
        application = Application.find(params.require(:id))
        authorize(application)

        update_pausable(application) do |allowed_parameters_for_update|
          application.update!(allowed_parameters_for_update)

          # Here we're raising the create event after the worker has filled in the
          # values for the source, but only the first time after the worker processes the message,
          # from there on we raise the normal update.
          first_time_superkey = (application.source.super_key? && params.try(:[], "extra")&.key?("_superkey"))
          raise_event_if(first_time_superkey, "Application.create", application.as_json)
          raise_event_if(first_time_superkey, "Records.create", application.bulk_message)

          # appending the extra keys in case of _superkey being updated.
          application.raise_event_for_update(allowed_parameters_for_update.keys + params.fetch("extra", {}).keys)
        end
      end
    end
  end
end
