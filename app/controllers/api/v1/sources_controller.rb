require "base64"
require "net/http"
require 'sources/api/clowder_config'

module Api
  module V1
    class SourcesController < ApplicationController
      include Api::V1::Mixins::DestroyMixin
      include Api::V1::Mixins::IndexMixin
      include Api::V1::Mixins::ShowMixin
      include Api::V1::Mixins::UpdateMixin

      def create
        source_data = params_for_create
        source_data["uid"] = SecureRandom.uuid if source_data["uid"].nil?
        source = Source.new(source_data).tap { |src| authorize(src) }
        source.save!

        raise_event("#{model}.create", source.as_json)

        render :json => source, :status => :created, :location => instance_link(source)
      end

      def check_availability
        source = Source.find(params[:source_id])

        source.availability_check

        render :json => {}, :status => :accepted
      end
    end
  end
end
