require "base64"
require "net/http"

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
        source = Source.create!(source_data)

        raise_event("#{model}.create", source.as_json)

        render :json => source, :status => :created, :location => instance_link(source)
      end

      def check_availability
        source = Source.find(params[:source_id])

        Sources::Api::Messaging.client.publish_topic(
          :service => "platform.topological-inventory.operations-#{source.source_type.name}",
          :event   => "Source.availability_check",
          :payload => {
            :params => {
              :source_id       => source.id.to_s,
              :external_tenant => source.tenant.external_tenant
            }
          }
        )

        check_application_availability(source)

        render :json => {}, :status => :accepted
      end

      private

      def check_application_availability(source)
        source.application_types.each do |app_type|
          url = app_type.availability_check_url
          next if url.blank?

          headers = {
            "Content-Type"  => "application/json",
            "x-rh-identity" => Base64.strict_encode64({'identity' => { 'account_number' => source.tenant.external_tenant }}.to_json)
          }

          uri = URI.parse(url)
          net_http = Net::HTTP.new(uri.host, uri.port)
          request  = Net::HTTP::Post.new(uri.request_uri, headers)
          request.body = { "source_id" => source.id.to_s }.to_json

          response = net_http.request(request)
          next if response.kind_of?(Net::HTTPSuccess)

          logger.info("Failed to request application availability check for source #{source.id} @ #{url} - #{response.message}")
        end
      end
    end
  end
end
