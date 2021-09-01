module Sources
  module Api
    class Request < Insights::API::Common::Request
      FORWARDABLE_HEADERS = Insights::API::Common::Request::FORWARDABLE_HEADER_KEYS + ["x-rh-sources-account-number"]

      # overwriting the super method with the same code - since we can't overwrite the
      # FORWARDABLE_HEADER_KEYS array in the superclass.
      def self.current_forwardable
        forwarding = FORWARDABLE_HEADERS.each_with_object({}) do |key, hash|
          hash[key] = current.headers[key] if current.headers.key?(key)
        end

        ensure_psk_and_rhid(forwarding)
      end

      def self.ensure_psk_and_rhid(headers)
        headers.tap do |h|
          # backwards compability for now while people move over to psk, this way we don't skip messages missing the x-rh-id header
          # we also don't want to overwrite the x-rh-id _if its there_
          if h["x-rh-sources-account-number"] && !h["x-rh-identity"]
            h["x-rh-identity"] = Base64.strict_encode64(
              JSON.dump({:identity => {:account_number => h["x-rh-sources-account-number"]}})
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
