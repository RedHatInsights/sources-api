module Api
  module V3x0
    class SourceTypesController < Api::V2x0::SourceTypesController
      include Mixins::IndexMixin
    end
  end
end
