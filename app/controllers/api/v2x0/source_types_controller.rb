module Api
  module V2x0
    class SourceTypesController < Api::V1x0::SourceTypesController
      undef_method(:create)
    end
  end
end
