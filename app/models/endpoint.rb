class Endpoint < ApplicationRecord
  include TenancyConcern
  belongs_to :source

  has_many   :authentications, :as => :resource, :dependent => :destroy

  validates :role, :uniqueness => { :scope => :source_id }

  def base_url_path
    URI::Generic.build(:scheme => scheme, :host => host, :port => port, :path => path).to_s
  end
end
