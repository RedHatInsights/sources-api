class Source < ApplicationRecord
  include TenancyConcern
  attribute :uid, :string, :default => -> { SecureRandom.uuid }

  has_many :applications, :dependent => :destroy
  has_many :application_types, :through => :applications
  has_many :endpoints, :autosave => true, :dependent => :destroy

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available partially_available unavailable] }, :allow_nil => true

  belongs_to :source_type

  delegate :scheme, :scheme=, :host, :host=, :port, :port=, :path, :path=,
           :to => :default_endpoint, :allow_nil => true
  validates :name, :presence => true, :allow_blank => false,
            :uniqueness => { :scope => :tenant_id }

  def default_endpoint
    default = endpoints.detect(&:default)
    default || endpoints.build(:default => true, :tenant => tenant)
  end
end
