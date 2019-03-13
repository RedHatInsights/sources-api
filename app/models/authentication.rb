class Authentication < ApplicationRecord
  include PasswordConcern
  include TenancyConcern
  encrypt_column :password

  belongs_to :resource, :polymorphic => true
end
