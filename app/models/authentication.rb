class Authentication < ApplicationRecord
  if ENV["VAULT_ADDR"].present?
    include VaultPasswordConcern
  else
    include PasswordConcern
  end
  include TenancyConcern
  encrypt_column :password

  belongs_to :resource, :polymorphic => true

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true
end
