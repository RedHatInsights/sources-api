class ApplicationAuthentication < ApplicationRecord
  include TenancyConcern
  belongs_to :application
  belongs_to :authentication
end
