class Authentication < ApplicationRecord
  include Pausable
  include PasswordConcern
  include TenancyConcern
  include EventConcern
  include AvailabilityStatusConcern
  encrypt_column :password

  belongs_to :resource, :polymorphic => true
  belongs_to :source, :optional => true

  has_many :application_authentications, :dependent => :destroy
  has_many :applications, :through => :application_authentications

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true

  before_validation :set_source
  validate :only_one_superkey, :if => proc { new_record? && source.super_key? }

  private

  def set_source
    self.source_id = if resource.instance_of?(Source)
                       errors.add(:only_superkey, "sources can have Authentication attached to Source") unless resource.super_key?

                       resource_id
                     else
                       resource.try(:source_id)
                     end
  end

  def only_one_superkey
    superkey_authtype = source.source_type.superkey_authtype
    return unless superkey_authtype && authtype == superkey_authtype

    if source.authentications.any? { |auth| auth.authtype == superkey_authtype }
      errors.add(:only_one_superkey, "Only one Authentication of #{superkey_authtype} is allowed on the Source.")
    end
  end

  def reset_availability
    super

    resource.try(:reset_availability!)
    applications.each do |app|
      app.reset_availability! unless app == resource
    end
  end
end
