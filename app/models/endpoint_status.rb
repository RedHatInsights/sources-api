class EndpointStatus < ApplicationRecord
  include ActiveRecord::PGEnum::Helper

  pg_enum :status => %w[unknown available unavailable supported unsupported]

  default_value_for :status, "unknown"
end
