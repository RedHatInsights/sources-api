class ApplicationController < ActionController::API
  include ManageIQ::API::Common::ApplicationControllerMixins::ApiDoc
  include ManageIQ::API::Common::ApplicationControllerMixins::Common
  include ManageIQ::API::Common::ApplicationControllerMixins::RequestBodyValidation
  include ManageIQ::API::Common::ApplicationControllerMixins::RequestPath

  BLACKLIST_PARAMS = [:tenant, :tenant_id]

  around_action :with_current_request

  rescue_from ActiveRecord::RecordNotFound do |exception|
    error_document = ManageIQ::API::Common::ErrorDocument.new.add(404, "Record not found")
    render :json => error_document.to_h, :status => :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    exception_msg = exception.message.split("\n").first.gsub("ActiveRecord::RecordInvalid: ", "")
    error_document = ManageIQ::API::Common::ErrorDocument.new.add(400, "Invalid parameter - #{exception_msg}")
    render :json => error_document.to_h, :status => :bad_request
  end

  rescue_from ActiveRecord::RecordNotUnique do |_exception|
    error_document = ManageIQ::API::Common::ErrorDocument.new.add(400, "Record not unique")
    render :json => error_document.to_h, :status => :bad_request
  end

  rescue_from ManageIQ::API::Common::Filter::Error do |exception|
    render :json => exception.error_document.to_h, :status => exception.error_document.status
  end

  rescue_from ActiveRecord::NotNullViolation do |exception|
    exception_msg = exception.message.split("\n").first.gsub("PG::NotNullViolation: ERROR:  ", "")
    error_document = ManageIQ::API::Common::ErrorDocument.new.add(400, "Missing parameter - #{exception_msg}")
    render :json => error_document.to_h, :status => :bad_request
  end

  private

  def with_current_request
    ManageIQ::API::Common::Request.with_request(request) do |current|
      begin
        if Tenant.tenancy_enabled? && current.required_auth?
          raise ManageIQ::API::Common::EntitlementError unless request_is_entitled?(current.entitlement)

          tenant = Tenant.find_or_create_by(:external_tenant => current.user.tenant)
          ActsAsTenant.with_tenant(tenant) { yield }
        else
          ActsAsTenant.without_tenant { yield }
        end
      rescue KeyError, ManageIQ::API::Common::IdentityError
        error_document = ManageIQ::API::Common::ErrorDocument.new.add(401, 'Unauthorized')
        render :json => error_document.to_h, :status => error_document.status
      rescue ManageIQ::API::Common::EntitlementError
        error_document = ManageIQ::API::Common::ErrorDocument.new.add(403, 'Forbidden')
        render :json => error_document.to_h, :status => error_document.status
      end
    end
  end

  def request_is_entitled?(entitlement)
    required_entitlements = %i[hybrid_cloud? insights?]
    required_entitlements.any? { |e| entitlement.send(e) }
  end

  def instance_link(instance)
    endpoint = instance.class.name.underscore
    version  = self.class.send(:api_version)
    send("api_#{version}_#{endpoint}_url", instance.id)
  end

  def raise_event(event, payload)
    headers = ManageIQ::API::Common::Request.current_forwardable
    Sources::Api::Events.raise_event(event, payload, headers)
  end

  def params_for_create
    # We already validate this with OpenAPI validator, that validates every request, so we shouldn't do it again here.
    body_params.except(*BLACKLIST_PARAMS).permit!
  end

  def safe_params_for_list
    # :limit & :offset can be passed in for pagination purposes, but shouldn't show up as params for filtering purposes
    @safe_params_for_list ||= params.merge(params_for_polymorphic_subcollection).permit(*permitted_params, :filter => {})
  end

  def permitted_params
    api_doc_definition.all_attributes + [:limit, :offset] + [subcollection_foreign_key]
  end

  def subcollection_foreign_key
    "#{request_path_parts["primary_collection_name"].singularize}_id"
  end

  def params_for_polymorphic_subcollection
    return {} unless subcollection?
    return {} unless reflection = primary_collection_model&.reflect_on_association(request_path_parts["subcollection_name"])
    return {} unless as = reflection.options[:as]
    {"#{as}_type" => primary_collection_model.name, "#{as}_id" => request_path_parts["primary_collection_id"]}
  end

  def primary_collection_model
    @primary_collection_model ||= request_path_parts["primary_collection_name"].singularize.classify.safe_constantize
  end

  def params_for_list
    safe_params = safe_params_for_list.slice(*all_attributes_for_index)
    if safe_params[subcollection_foreign_key_using_through_relation]
      # If this is a through relation, we need to replace the :foreign_key by the foreign key with right table
      # information. So e.g. :container_images with :tags subcollection will have {:container_image_id => ID} and we need
      # to replace it with {:container_images_tags => {:container_image_id => ID}}, where :container_images_tags is the
      # name of the mapping table.
      safe_params[through_relation_klass.table_name.to_sym] = {
        subcollection_foreign_key_using_through_relation => safe_params.delete(subcollection_foreign_key_using_through_relation)
      }
    end

    safe_params
  end

  def through_relation_klass
    return unless subcollection?
    return unless reflection = primary_collection_model&.reflect_on_association(request_path_parts["subcollection_name"])
    return unless through = reflection.options[:through]

    primary_collection_model&.reflect_on_association(through).klass
  end

  def through_relation_name
    # Through relation name taken from the subcollection model side, so we can use this for table join.
    return unless through_relation_klass
    return unless through_relation_association = model.reflect_on_all_associations.detect { |x| !x.polymorphic? && x.klass == through_relation_klass }

    through_relation_association.name
  end

  def subcollection_foreign_key_using_through_relation
    return unless through_relation_klass

    subcollection_foreign_key
  end

  def all_attributes_for_index
    api_doc_definition.all_attributes + [subcollection_foreign_key_using_through_relation]
  end

  def filtered
    ManageIQ::API::Common::Filter.new(model, safe_params_for_list[:filter], api_doc_definition).apply
  end

  def pagination_limit
    safe_params_for_list[:limit]
  end

  def pagination_offset
    safe_params_for_list[:offset]
  end

  def params_for_update
    body_params.except(*BLACKLIST_PARAMS).permit(*api_doc_definition.all_attributes - api_doc_definition.read_only_attributes)
  end
end
