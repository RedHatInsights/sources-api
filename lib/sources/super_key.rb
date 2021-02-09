module Sources
  class SuperKey
    attr_reader :output

    def initialize(provider: nil, source_id: nil, applications: nil)
      @provider = provider
      @source_id = source_id
      @applications = applications
    end

    def create
      src = Source.find(@source_id)

      @applications.each do |app|
        apptype = case app
                  when "cost-management"
                    ApplicationType.find_by(:name => "/insights/platform/cost-management")
                  when "subscription-watch"
                    ApplicationType.find_by(:name => "/insights/platform/cloud-meter")
                  else
                    raise "unsupported superkey application type #{app}"
                  end

        extra = {}.tap do |e|
          case @provider
          when "amazon"
            # account # to substitute in resources
            e[:account] = apptype
                          .app_meta_data
                          .detect { |field| field.name == "aws_wizard_account_number" }
                          .payload

            # type of authentication to return
            e[:result_type] = apptype.supported_authentication_types["amazon"]&.first
          end
        end

        Sources::Api::Messaging.send_superkey_steps(
          :tenant         => src.tenant,
          :source_id      => src.id,
          :type           => apptype,
          :authentication => src.super_key,
          :provider       => @provider,
          :extra          => extra
        )
      end
    end

    def teardown
      # TODO:
      # 1. look up application type + provider
      # 2. set up extra with guid from application.extra
      # 3. send delete request
    end
  end
end
