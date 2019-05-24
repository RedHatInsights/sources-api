module Api
  module V1
    class EndpointsController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin
      include Api::V1::Mixins::UpdateMixin

      def create
        endpoint = Endpoint.create!(params_for_create)
        raise_event("#{model}.create", endpoint.as_json)
        render :json => endpoint, :status => :created, :location => instance_link(endpoint)
      end
    end
  end
end
