class Source < ApplicationRecord
  include TenancyConcern
  attribute :uid, :string, :default => -> { SecureRandom.uuid }

  has_many :applications
  has_many :application_types, :through => :applications

  has_many :endpoints, :autosave => true
  has_many :availabilities, :as => :resource, :dependent => :destroy, :inverse_of => :resource

  belongs_to :source_type

  delegate :scheme, :scheme=, :host, :host=, :port, :port=, :path, :path=,
           :to => :default_endpoint, :allow_nil => true

  def default_endpoint
    default = endpoints.detect(&:default)
    default || endpoints.build(:default => true, :tenant => tenant)
  end
end
