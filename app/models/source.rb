class Source < ApplicationRecord
  include TenancyConcern
  include EventConcern
  include AvailabilityStatusConcern
  attribute :uid, :string, :default => -> { SecureRandom.uuid }

  has_many :applications, :dependent => :destroy
  has_many :application_types, :through => :applications
  has_many :endpoints, :autosave => true, :dependent => :destroy
  has_many :authentications, :dependent => :destroy

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available partially_available unavailable] }, :allow_nil => true
  validates :app_creation_workflow, :inclusion => {:in => %w[manual_configuration account_authorization]}

  belongs_to :source_type

  delegate :scheme, :scheme=, :host, :host=, :port, :port=, :path, :path=,
           :to => :default_endpoint, :allow_nil => true
  validates :name, :presence => true, :allow_blank => false,
            :uniqueness => { :scope => :tenant_id }

  def default_endpoint
    default = endpoints.detect(&:default)
    default || endpoints.build(:default => true, :tenant => tenant)
  end

  def super_key
    authentications.find_by!(:authtype => "superkey")
  end

  def remove_availability_status(source = nil)
    return if source == :Application && endpoints.any?

    self.availability_status = nil
    self.last_checked_at = nil
  end

  def remove_availability_status!(source = nil)
    remove_availability_status(source)
    save!
  end
end
