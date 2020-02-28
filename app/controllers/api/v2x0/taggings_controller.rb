module Api
  module V2x0
    class TaggingsController < ApplicationController
      include Api::V1::Mixins::IndexMixin
      include Insights::API::Common::TaggingMethods

      # Present these as tags
      private_class_method def self.api_doc_definition
        @api_doc_definition ||= api_doc.definitions["Tag"]
      end

      def self.presentation_name
        "Tag".freeze
      end

      private

      def model
        primary_collection_model.tagging_relation_name.to_s.singularize.classify.safe_constantize
      end
    end
  end
end
