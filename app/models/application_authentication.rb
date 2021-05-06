class ApplicationAuthentication < ApplicationRecord
  include Pausable
  include TenancyConcern
  include EventConcern
  belongs_to :application
  belongs_to :authentication

  before_validation(:on => :create) { |i| i.send("tenant=", i.authentication.send("tenant")) }

  def self.list_operation_id
    "listAllApplicationAuthentications"
  end
end
