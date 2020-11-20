class Authentication < ApplicationRecord
  include PasswordConcern
  include TenancyConcern
  include EventConcern
  encrypt_column :password

  belongs_to :resource, :polymorphic => true
  belongs_to :source, :optional => true

  has_many :application_authentications, :dependent => :destroy
  has_many :applications, :through => :application_authentications

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true

  before_validation :set_source

  private

  def set_source
    self.source_id = resource&.source_id
  end
end
