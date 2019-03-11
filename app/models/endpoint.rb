class Endpoint < ApplicationRecord
  belongs_to :tenant
  belongs_to :source

  has_many   :authentications, :as => :resource

  validates :role, :uniqueness => { :scope => :source_id }

  acts_as_tenant(:tenant)

  def base_url_path
    URI::Generic.build(:scheme => scheme, :host => host, :port => port, :path => path).to_s
  end
end
