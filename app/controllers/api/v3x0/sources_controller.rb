module Api
  module V3x0
    class SourcesController < Api::V2x0::SourcesController
      include Mixins::IndexMixin
    end
  end
end
