class Application < ApplicationRecord
  belongs_to :tenant
  belongs_to :source
  belongs_to :application_type
end
