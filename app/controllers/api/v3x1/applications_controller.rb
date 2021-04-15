module Api
  module V3x1
    class ApplicationsController < Api::V3x0::ApplicationsController
      def pause
        app = Application.find(params.require(:id)).tap { |s| authorize(s) }
        app.discard!

        head 204
      end

      def unpause
        app = Application.find(params.require(:id)).tap { |s| authorize(s) }
        app.undiscard!

        head 202
      end
    end
  end
end
