class Source < ApplicationRecord
  attribute :uid, :string, :default => -> { SecureRandom.uuid }

  has_many :endpoints, :autosave => true
  has_many :availabilities, :as => :resource, :dependent => :destroy, :inverse_of => :resource

  belongs_to :source_type
  belongs_to :tenant

  delegate :scheme, :scheme=, :host, :host=, :port, :port=, :path, :path=,
           :to => :default_endpoint, :allow_nil => true

  acts_as_tenant(:tenant)

  def default_endpoint
    default = endpoints.detect(&:default)
    default || endpoints.build(:default => true, :tenant => tenant)
  end
end
