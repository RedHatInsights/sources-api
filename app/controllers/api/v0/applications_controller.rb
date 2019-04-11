module Api
  module V0
    class ApplicationsController < ApplicationController
      include Api::V0::Mixins::DestroyMixin
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin
      include Api::V0::Mixins::UpdateMixin

      def create
        application = Application.create!(params_for_create)
        render :json => application, :status => :created, :location => instance_link(application)
      end
    end
  end
end
