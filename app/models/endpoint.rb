class Endpoint < ApplicationRecord
  include TenancyConcern
  belongs_to :source

  has_many   :authentications, :as => :resource, :dependent => :destroy

  validates :role, :uniqueness => { :scope => :source_id }
  validates :default, :uniqueness => {:scope => :source_id}, :if => :default

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true

  def base_url_path
    URI::Generic.build(:scheme => scheme, :host => host, :port => port, :path => path).to_s
  end
end
