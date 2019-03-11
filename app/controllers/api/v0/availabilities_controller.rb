module Api
  module V0
    class AvailabilitiesController < ApplicationController
      include Api::V0::Mixins::IndexMixin
    end
  end
end
