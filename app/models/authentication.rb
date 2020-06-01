class Authentication < ApplicationRecord
  include PasswordConcern
  include TenancyConcern
  include EventConcern
  encrypt_column :password

  belongs_to :resource, :polymorphic => true

  has_many :application_authentications
  has_many :applications, :through => :application_authentications

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true
end
