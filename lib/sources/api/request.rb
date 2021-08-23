module Sources
  module Api
    class Request < Insights::API::Common::Request
      # map of extra headers mapping with a name as well as a function to get the value if it isn't present already.
      # this is currently only useful for the account-number changes since we need that account number to be present
      # on the kafka messages even if the request came from outside (e.g. 3scale)
      EXTRA_HEADERS = {
        "x-rh-sources-account-number" => proc { Sources::Api::Request.current.identity["identity"]["account_number"] }
      }.freeze

      def self.current_forwardable
        super.tap do |headers|
          EXTRA_HEADERS.each do |name, func|
            headers[name] = (current.headers[name] || func.call)
          end
        end
      end
    end
  end
end
