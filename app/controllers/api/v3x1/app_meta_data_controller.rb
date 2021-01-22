module Api
  module V3x1
    class AppMetaDataController < ApplicationController
      include ::Api::V1::Mixins::ShowMixin

      # things are starting to get hairy, since v3x0 is overriding the `index` method,
      # but not providing the other two, so we need to include them both.
      include ::Api::V1::Mixins::IndexMixin
      include ::Api::V3x0::Mixins::IndexMixin

      def model
        AppMetaData
      end
    end
  end
end
