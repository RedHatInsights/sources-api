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
    end
  end
end
