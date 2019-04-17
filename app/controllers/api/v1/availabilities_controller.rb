module Api
  module V1
    class AvailabilitiesController < ApplicationController
      include Api::V1::Mixins::IndexMixin
    end
  end
end
