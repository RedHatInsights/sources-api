class Endpoint < ApplicationRecord
  include Pausable
  include TenancyConcern
  include EventConcern
  include AvailabilityStatusConcern
  belongs_to :source

  has_many   :authentications, :as => :resource, :dependent => :destroy

  validates :role, :uniqueness => { :scope => :source_id }
  validates :default, :uniqueness => {:scope => :source_id}, :if => :default

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true

  before_save :set_default, :if => proc { source.endpoints.count.zero? }

  def base_url_path
    URI::Generic.build(:scheme => scheme, :host => host, :port => port, :path => path).to_s
  end

  def set_default
    self.default = true
  end

  def reset_availability
    super

    source.reset_availability!
  end
end
