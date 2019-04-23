module Api
  module V1
    class SourcesController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin
      include Api::V1::Mixins::UpdateMixin

      def create
        source = Source.create!(params_for_create.merge("uid" => SecureRandom.uuid))

        Sources::Api::Events.raise_event("#{model}.create", source.as_json)

        render :json => source, :status => :created, :location => instance_link(source)
      end
    end
  end
end
