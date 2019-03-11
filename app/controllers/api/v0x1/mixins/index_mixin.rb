module Api
  module V0x1
    module Mixins
      module IndexMixin
        def index
          raise_unless_primary_instance_exists
          render json: ManageIQ::API::Common::PaginatedResponse.new(
            base_query: scoped(model.where(params_for_list)),
            request: request,
            limit: pagination_limit,
            offset: pagination_offset
          ).response
        end

        def scoped(relation)
          if through_relation_klass
            relation = relation.joins(through_relation_name)
          end

          relation
        end
      end
    end
  end
end
