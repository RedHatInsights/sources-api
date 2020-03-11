class Application < ApplicationRecord
  include TenancyConcern
  belongs_to :source
  belongs_to :application_type

  has_many :application_authentications
  has_many :authentications, :through => :application_authentications

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true
end
