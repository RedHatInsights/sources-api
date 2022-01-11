module Api
  module V3x0
    module Mixins
      module IndexMixin
        def index
          raise_unless_primary_instance_exists
          render :json => Insights::API::Common::PaginatedResponseV2.new(
            :base_query => scoped(filtered.where(params_for_list)),
            :request    => request,
            :limit      => pagination_limit,
            :offset     => pagination_offset,
            :sort_by    => query_sort_by
          ).response
        end
      end
    end
  end
end
