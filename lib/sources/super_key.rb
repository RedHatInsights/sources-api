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
          case @application.application_type.name
          when "/insights/platform/cloud-meter"
            # subswatch has a few values dynamically substituted.
            e[:account] = SubscriptionWatchInfo.fetch_account_number
            payload.find { |step| step.payload =~ /DYNAMIC/ }.payload = SubscriptionWatchInfo.fetch_policy_json
          else
            # account number to substitute in resources
            acct = @application.application_type
                               .app_meta_data
                               .detect { |field| field.name == "aws_wizard_account_number" }
                               &.payload

            e[:account] = acct if acct
          end

          # type of authentication to return
          e[:result_type] = @application.application_type.supported_authentication_types["amazon"]&.first
        end
      end

      Sources::Api::Messaging.send_superkey_create_request(
        :application => @application,
        :super_key   => src.super_key_credential,
        :provider    => @provider,
        :extra       => extra,
        :steps       => payload.to_json
      )
    end

    def teardown
      Sources::Api::Messaging.send_superkey_destroy_request(
        :application => @application,
        :steps       => payload.to_json
      )
    end

    def payload
      @payload ||= begin
        @application.application_type.super_key_meta_data.each do |m|
          m.payload = JSON.dump(m.payload)
        end
      end
    end
  end
end
