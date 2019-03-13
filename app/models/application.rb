class Application < ApplicationRecord
  include TenancyConcern
  belongs_to :source
  belongs_to :application_type
end
