class EndpointTag < ApplicationRecord
  belongs_to :tenant
  belongs_to :endpoint
  belongs_to :tag
end
