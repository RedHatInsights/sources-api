module Sources
  module Api
    class Exception     < ::Exception; end
    class NoTenantError < ::StandardError; end
  end
end
