module Sources
  module Api
    class Request < Insights::API::Common::Request
      EXTRA_HEADERS = %w[x-rh-sources-account-number].freeze

      def self.current_forwardable
        super.tap do |headers|
          EXTRA_HEADERS.each do |extra|
            headers[extra] = current.headers[extra]
          end
        end
      end
    end
  end
end
