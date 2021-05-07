require "sources/api/internal_docs"

module Internal
  module V2x0
    class TenantsController < ::ApplicationController
      include ::Api::V1::Mixins::IndexMixin
      include ::Api::V1::Mixins::ShowMixin

      def self.api_doc
        @api_doc ||= ::Sources::Api::InternalDocs.instance['2.0']
      end
    end
  end
end
