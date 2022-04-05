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
  validate :both_username_and_password, :if => proc { resource.kind_of?(Source) && source.super_key? }

  # This will populate the go-side's password column on create.
  before_save do
    if !Rails.env.test?
      self.password_hash = GoEncryption.encrypt(self.password) if self.password_hash.blank? && self.password.present?
    end
  end

  # if an authentication gets created on the go side it won't have populated the `password` column, so we populate it
  # on initilization on the rails side (in case we have to switch back and forth)
  after_initialize do
    if !Rails.env.test?
      update!(:password => GoEncryption.decrypt(self.password_hash)) if self.password.blank? && self.password_hash.present?
    end
  end

  private

  def set_source
    self.source_id = if resource.instance_of?(Source)
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

  def both_username_and_password
    if username.nil? || password.nil?
      errors.add(:both_username_and_password, "superkey authentications require both username and password")
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
