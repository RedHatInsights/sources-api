module Api
  module V3x1
    class ApplicationsController < Api::V3x0::ApplicationsController
      def pause
        app = Application.find(params.require(:application_id)).tap { |s| authorize(s) }
        app.discard!
        AvailabilityMessageJob.perform_later("Application.pause", app, headers.to_h)

        head 204
      end

      def unpause
        app = Application.find(params.require(:application_id)).tap { |s| authorize(s) }
        app.undiscard!
        AvailabilityMessageJob.perform_later("Application.unpause", app, headers.to_h)

        head 202
      end
    end
  end
end
