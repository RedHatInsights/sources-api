module Api
  module V0
    class EndpointsController < ApplicationController
      include Api::V0::Mixins::DestroyMixin
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin
      include Api::V0::Mixins::UpdateMixin

      def create
        endpoint = Endpoint.create!(params_for_create)
        raise_event(params_for_create.to_h.merge("id" => endpoint.id.to_s))
        render :json => endpoint, :status => :created, :location => instance_link(endpoint)
      end
    end
  end
end
