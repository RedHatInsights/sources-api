module Api
  module V0
    class SourcesController < ApplicationController
      include Api::V0::Mixins::DestroyMixin
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin
      include Api::V0::Mixins::UpdateMixin

      def create
        create_params = params_for_create.merge!("uid" => SecureRandom.uuid)
        source = Source.create!(create_params)
        raise_event __method__, create_params.to_h.merge("id" => source.id.to_s)
        render :json => source, :status => :created, :location => instance_link(source)
      end
    end
  end
end
