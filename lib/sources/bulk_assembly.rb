module Sources
  class BulkAssembly
    attr_reader :output

    def initialize(params)
      @sources = params[:sources]
      @endpoints = params[:endpoints]
      @applications = params[:applications]
      @authentications = params[:authentications]
    end

    def process
      Source.transaction do
        @output = {}.tap do |output|
          output[:sources] = create_sources(@sources)
          output[:endpoints] = create_endpoints(@endpoints, output)
          output[:applications] = create_applications(@applications, output)
          output[:authentications] = create_authentications(@authentications, output)
        end

        self
      rescue => e
        Rails.logger.error("Error bulk processing from payload: Sources: #{@sources}, Endpoints: #{@endpoints}, Applications: #{@applications}, Authentications: #{@authentications}. Error: #{e}")

        raise
      end
    end

    def create_sources(sources)
      sources&.map do |source|
        srct = SourceType.find_by!(:name => source.delete(:type))

        Source.create!(source.merge!(:source_type => srct))
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
        appt = get_application_type(app.delete(:type))

        ::Application.create!(app.merge!(:source_id => src.id, :application_type_id => appt.id))
      end
    end

    def create_authentications(authentications, resources)
      authentications&.map do |auth|
        ptype = auth.delete(:resource_type)
        parent = case ptype
                 when "source"
                   find_resource(resources, :sources, auth.delete(:resource_name))
                 when "endpoint"
                   find_resource(resources, :endpoints, auth.delete(:resource_name), :host)
                 when "application"
                   appt = get_application_type(auth.delete(:resource_name))
                   find_resource(resources, :applications, appt, :application_type)
                 end

        Authentication.create!(auth.merge!(:resource => parent)).tap do |newauth|
          # create the application_authentication relation if the parent was an application.
          ApplicationAuthentication.create!(:authentication => newauth, :application => parent) if ptype == "application"
        end
      end
    end

    private

    def find_resource(resources, rtype, rname, field = :name)
      # use the safe operator in the case of creating a subresource on an existing source
      parent = resources[rtype]&.detect { |resource| resource.send(field) == rname }

      # if the parent is a source, it's possible that it was already created in the db
      # so we need to try and look it up potentially.
      if rtype == :sources && parent.nil?
        parent = Source.find_by(:name => rname) || Source.find_by(:id => rname)
      end

      raise ActiveRecord::ActiveRecordError, "no applicable #{rtype} for #{rname}" if parent.nil?

      parent
    end

    def get_application_type(type)
      ApplicationType.all.detect { |apptype| apptype.name.match?(type) }.tap do |found|
        raise ActiveRecord::ActiveRecordError, "no applicable application type found for #{type}" if found.nil?
      end
    end
  end
end
