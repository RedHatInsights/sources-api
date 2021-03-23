module Api
  module V3x1
    class BulkCreateController < ApplicationController
      def create
        # Authorize creating a new source, before we go through the processing.
        authorize(Source.new)
        bulk = Sources::BulkAssembly.new(params_for_create).process

        # source + endpoints can be raised normally
        [:sources, :endpoints].each do |type|
          bulk.output[type]&.each do |e|
            raise_event("#{type.to_s.capitalize.singularize}.create", e.as_json)
          end
        end

        # applications only get raised if they're not superkey applications
        bulk.output[:applications]&.each do |app|
          # we do not want to raise the create event since the application has
          # not been processed by the superkey worker.
          #
          # also need to store the headers on create, that way we can send them when the superkey worker posts back.
          if app.source.super_key?
            app.update!(:superkey_data => {:headers => Insights::API::Common::Request.current_forwardable})
          else
            raise_event("Application.create", app.as_json)
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
