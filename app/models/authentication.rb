require "password_concern"

class Authentication < ApplicationRecord
  include PasswordConcern
  encrypt_column :password

  belongs_to :tenant
  belongs_to :resource, :polymorphic => true

  acts_as_tenant(:tenant)
end
