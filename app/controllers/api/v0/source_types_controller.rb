module Api
  module V0
    class SourceTypesController < ApplicationController
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin

      def create
        source = model.create!(params_for_create)
        render :json => source, :status => :created, :location => instance_link(source)
      end
    end
  end
end
