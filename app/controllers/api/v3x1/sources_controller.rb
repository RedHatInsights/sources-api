module Api
  module V3x1
    class SourcesController < Api::V3x0::SourcesController
      def destroy
        source = Source.find(params.require(:id)).tap { |s| authorize(s) }

        if source.super_key?
          SuperkeyDeleteJob.perform_later(source, Insights::API::Common::Request.current_forwardable)
          head :accepted
        else
          source.destroy!
          head :no_content
        end
      end

      def pause
        src = Source.find(params.require(:source_id)).tap { |s| authorize(s) }
        # the after_discard callback on the Application model handles discarding the source.
        src.applications.each do |app|
          app.discard!
          AvailabilityMessageJob.perform_later("Application.pause", app.to_json, Insights::API::Common::Request.current_forwardable)
        end

        head 204
      end

      def unpause
        src = Source.find(params.require(:source_id)).tap { |s| authorize(s) }
        # the after_discard callback on the Application model handles undiscarding the source.
        src.applications.each do |app|
          app.undiscard!
          AvailabilityMessageJob.perform_later("Application.unpause", app.to_json, Insights::API::Common::Request.current_forwardable)
        end

        head 202
      end
    end
  end
end
