module Sources
  class SuperKey
    attr_reader :output

    def initialize(application:, provider: nil, source_id: nil)
      @provider = provider
      @source_id = source_id
      @application = application
    end

    def create
      src = Source.find(@source_id)

      extra = {}.tap do |e|
        case @provider
        when "amazon"
          # account number to substitute in resources
          e[:account] = @application.application_type
                                    .app_meta_data
                                    .detect { |field| field.name == "aws_wizard_account_number" }
                                    .payload

          # type of authentication to return
          e[:result_type] = @application.application_type.supported_authentication_types["amazon"]&.first
        end
      end

      Sources::Api::Messaging.send_superkey_create_request(
        :application => @application,
        :super_key   => src.super_key,
        :provider    => @provider,
        :extra       => extra
      )
    end

    def teardown
      Sources::Api::Messaging.send_superkey_destroy_request(
        :application => @application
      )
    end
  end
end
