module Internal
  module V0
    class AuthenticationsController < ::ApplicationController
      def show
        record = model.find(params_for_show[:id])
        render json: record.as_json(:prefixes => [request.path]).merge(encrypted_attributes(record))
      rescue ActiveRecord::RecordNotFound
        head :not_found
      end

      private

      def params_for_show
        @params_for_show ||= params.permit(:id, :expose_encrypted_attribute => []).tap { |i| i.require(:id) }
      end

      def encrypted_attributes_to_expose
        Array(params_for_show[:expose_encrypted_attribute].presence) & model.encrypted_columns
      end

      def encrypted_attributes(record)
        encrypted_attributes_to_expose.each_with_object({}) do |attribute_name, h|
          h[attribute_name] = record.public_send(attribute_name) if record.attributes.key?(attribute_name)
        end
      end
    end
  end
end
