module Internal
  module V2x0
    class SourcesController < ::ApplicationController
      include ::Internal::V2x0::Mixins::OpenApiMixin
      include ::Internal::V2x0::Mixins::IndexMixin
    end
  end
end
