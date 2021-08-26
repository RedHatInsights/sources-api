module Sources
  module Api
    class Request < Insights::API::Common::Request
      def self.current_forwardable
        super.tap do |headers|
          ensure_psk_and_rhid(headers)
        end
      end

      def self.ensure_psk_and_rhid(headers)
        headers.tap do |h|
          # backwards compability for now while people move over to psk, this way we don't skip messages missing the x-rh-id header
          # we also don't want to overwrite the x-rh-id _if its there_
          if h["x-rh-sources-account-number"] && !h["x-rh-identity"]
            h["x-rh-identity"] = Base64.strict_encode64(
              JSON.dump(
                {
                  :identity => {
                    :account_number => h["x-rh-sources-account-number"],
                    :user           => {:is_org_admin => true}
                  }
                }
              )
            )
            # generate x-rh-sources-account-number if its not there, but x-rh-id is.
          elsif h["x-rh-identity"] && !h["x-rh-sources-account-number"]
            parsed_identity = JSON.parse(Base64.decode64(h["x-rh-identity"]))
            h["x-rh-sources-account-number"] = parsed_identity["identity"]["account_number"]
          end
        end
      end
    end
  end
end
