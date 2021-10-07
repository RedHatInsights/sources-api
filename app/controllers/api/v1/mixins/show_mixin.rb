module Api
  module V1
    module Mixins
      module ShowMixin
        def show
          authorize(model.new)

          render json: model.find_by!(limited_access.merge!(:id => params.require(:id)))
        end

        def limited_access
          {}.tap do |extra|
            case model.to_s
            when "Source"
              if Rails.env.production? && Sources::Api::Request.current.system&.cn
                extra["source_type_id"] = SourceType.find_by(:name => "satellite")&.id
              end
            end
          end
        rescue Insights::API::Common::IdentityError # if psk is used we don't have a "current" request
          {}
        end
      end
    end
  end
end
