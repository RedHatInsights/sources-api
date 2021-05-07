require "insights/api/common/open_api/docs"

module Sources
  module Api
    class InternalDocs < ::Insights::API::Common::OpenApi::Docs
      def self.instance
        @instance ||= new(Dir.glob(Rails.root.join("private", "doc", "openapi*.json")))
      end
    end
  end
end
