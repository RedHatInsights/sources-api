class EndpointStatus < ApplicationRecord
  include PGEnum(:status => %w[unknown available unavailable supported unsupported])

  default_value_for :status, "unknown"
end
