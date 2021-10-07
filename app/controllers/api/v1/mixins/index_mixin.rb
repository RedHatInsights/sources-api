module Api
  module V1
    module Mixins
      module IndexMixin
        def index
          authorize(filtered.new)

          raise_unless_primary_instance_exists
          render :json => Insights::API::Common::PaginatedResponse.new(
            :base_query => scoped(filtered.where(params_for_list.merge!(limited_access))),
            :request    => request,
            :limit      => pagination_limit,
            :offset     => pagination_offset,
            :sort_by    => query_sort_by
          ).response
        end

        def scoped(relation)
          if through_relation_klass
            relation = relation.joins(through_relation_name)
          end

          relation
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

        def raise_unless_primary_instance_exists
          return unless subcollection?

          klass = request_path_parts["primary_collection_name"].singularize.camelize.safe_constantize
          klass.find(request_path_parts["primary_collection_id"].to_i)
        end
      end
    end
  end
end
