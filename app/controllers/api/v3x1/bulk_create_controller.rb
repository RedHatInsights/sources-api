module Api
  module V3x1
    class BulkCreateController < ApplicationController
      def create
        # Authorize creating a new source, before we go through the processing.
        authorize(Source.new)
        bulk = Sources::BulkAssembly.new(params_for_create).process

        # source, endpoints, applications all can be raised normally
        [:sources, :endpoints, :applications].each do |type|
          bulk.output[type]&.each do |e|
            raise_event("#{type.to_s.capitalize.singularize}.create", e.as_json)
          end
        end

        # authentications are special since they have a "hidden"
        # ApplicationAuthentication subresource
        bulk.output[:authentications]&.each do |auth|
          raise_event("Authentication.create", auth.as_json)

          auth.application_authentications.each do |app_auth|
            raise_event("ApplicationAuthentication.create", app_auth.as_json)
          end
        end

        render :status => 201, :json => bulk.output
      end
    end
  end
end
