module Sources
  class BulkAssembly
    attr_reader :output

    def initialize(params)
      @sources = params[:sources]
      @endpoints = params[:endpoints]
      @applications = params[:applications]

      # separate out the superkey authentications.
      @superkeys, @authentications = params[:authentications]&.partition do |auth|
        superkey_authtypes.include?(auth[:authtype])
      end
    end

    def process
      Source.transaction do
        @output = {}.tap do |output|
          # Create the base source(s)
          output[:sources] = create_sources(@sources)

          # Create the superkey authentications (if there are any)
          output[:authentications] = create_authentications(@superkeys, output)

          # Create the endpoints
          output[:endpoints] = create_endpoints(@endpoints, output)

          # Create the applications (sends superkey requests via callback)
          output[:applications] = create_applications(@applications, output)

          # Create the remaining authentications that aren't superkeys.
          if output[:authentications]
            output[:authentications].concat(create_authentications(@authentications, output))
          else
            output[:authentications] = create_authentications(@authentications, output)
          end
        end

        self
      rescue => e
        Rails.logger.error("Error bulk processing from payload: Sources: #{@sources}, Endpoints: #{@endpoints}, Applications: #{@applications}, Authentications: #{@authentications}. Error: #{e.message}\n#{e.backtrace}")

        raise
      end
    end

    def create_sources(sources)
      sources&.map do |source|
        # get the source type by ID or by type string
        source_type = SourceType.find_by(:id => source.delete(:source_type_id)) || SourceType.find_by(:name => source.delete(:source_type_name))

        raise ActiveRecord::ActiveRecordError, "Source Type not found" if source_type.nil?

        extra_params = {
          :source_type         => source_type,
          :availability_status => if source[:app_creation_workflow] == Source::SUPERKEY_WORKFLOW
                                    "in_progress"
                                  end
        }

        Source.create!(source.merge!(extra_params))
      end
    end

    def create_endpoints(endpoints, resources)
      endpoints&.map do |endpoint|
        src = find_resource(resources, :sources, endpoint.delete(:source_name))

        Endpoint.create!(endpoint.merge!(:source_id => src.id))
      end
    end

    def create_applications(applications, resources)
      applications&.map do |app|
        src = find_resource(resources, :sources, app.delete(:source_name))
        # Get the application by id or lookup by type string
        appt = ApplicationType.find_by(:id => app.delete(:application_type_id)) || get_application_type(app.delete(:application_type_name))

        ::Application.create!(app.merge!(:source_id => src.id, :application_type_id => appt.id))
      end
    end

    def create_authentications(authentications, resources)
      authentications&.map do |auth|
        resource_type = auth.delete(:resource_type)
        resource_name = auth.delete(:resource_name)

        # complicated logic here - since the source/endpoint/application can all
        # be looked up differently
        parent = case resource_type
                 when "source"
                   find_resource(resources, :sources, resource_name)
                 when "endpoint"
                   find_resource(resources, :endpoints, resource_name, :host)
                 when "application"
                   # we have to look up the application by id before jumping
                   # into looking for the current resources since it matches by
                   # type
                   ::Application.find_by(:id => resource_name) || find_resource(resources, :applications, get_application_type(resource_name), :application_type)
                 end

        Authentication.create!(auth.merge!(:resource => parent)).tap do |newauth|
          # create the application_authentication relation if the parent was an
          # application.
          ApplicationAuthentication.create!(:authentication => newauth, :application => parent) if resource_type == "application"
        end
      end
    end

    # method that returns the proper bulk_message for the payload. It keys off of whether
    # there is an authentication first, then goes to application after. That way both bases
    # are covered where a user might use bulk_create on an app w/o an authentication yet.
    #
    # when determining which app/auth to go off of - we go with first one, just because
    # the bulk_message output will produce the same message independent of which of
    # the 2 (or more) subresources exist
    def process_message
      if @output[:authentications]&.any?
        auth = @output[:authentications].first
        auth.bulk_message
      elsif @output[:applications]&.any?
        app = @output[:applications].first
        # we don't raise application messages except for non-superkey sources at first,
        # the worker will post the resources back later.
        app.bulk_message unless app.source.super_key?
      end
    end

    private

    # this method finds a resource that has already been created _in this
    # payload, which is what the `resources` param is
    # `resource_name` is the matcher
    # `resource_type` is the type that has been already created, e.g. :sources for
    # a source that was already created. It is the key in the response hash.
    # `field` is which message to send the existing objects to get a match
    def find_resource(resources, resource_type, resource_name, field = :name)
      # use the safe operator in the case of creating a subresource on an
      # existing source
      parent = resources[resource_type]&.detect { |resource| resource.send(field) == resource_name }

      # if the parent is a source, it's possible that it was already created in
      # the db so we need to try and look it up
      if parent.nil?
        case resource_type
        when :sources
          parent = Source.find_by(:name => resource_name) || Source.find_by(:id => resource_name)
        when :endpoints
          parent = Endpoint.find_by(:host => resource_name) || Endpoint.find_by(:id => resource_name)
        end
      end

      raise ActiveRecord::ActiveRecordError, "no applicable #{resource_type} for #{resource_name}" if parent.nil?

      parent
    end

    def get_application_type(type)
      ApplicationType.all.detect { |apptype| apptype.name.match?(type) }.tap do |found|
        raise ActiveRecord::ActiveRecordError, "no applicable application type found for #{type}" if found.nil?
      end
    end

    def superkey_authtypes
      @superkey_authtypes ||= SourceType.all.map(&:superkey_authtype).compact!
    end
  end
end
