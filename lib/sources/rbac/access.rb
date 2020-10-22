module Sources
  module RBAC
    class Access
      class << self
        def enabled?
          Insights::API::Common::RBAC::Access.enabled?
        end

        def write_access?
          access.accessible?("*", "*") # sources:*:* is the only permission as of now.
        end

        def access
          @access ||= Insights::API::Common::RBAC::Access.new.process
        end
      end
    end
  end
end
