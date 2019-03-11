module Api
  module V0
    module Mixins
      module IndexMixin
        def index
          raise_unless_primary_instance_exists
          render json: scoped(model.where(params_for_list))
        end

        def scoped(relation)
          if model.respond_to?(:taggable?) && model.taggable?
            ref_schema = {model.tagging_relation_name => :tag}

            relation = relation.includes(ref_schema).references(ref_schema)
          elsif through_relation_klass
            relation = relation.joins(through_relation_name)
          end

          relation
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
