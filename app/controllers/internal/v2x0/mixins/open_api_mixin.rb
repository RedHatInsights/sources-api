module Internal
  module V2x0
    module Mixins
      module OpenApiMixin
        extend ActiveSupport::Concern
        module ClassMethods
          def api_doc
            @api_doc ||= ::Sources::Api::InternalDocs.instance['2.0']
          end
        end
      end
    end
  end
end
