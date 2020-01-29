class Tenant < ApplicationRecord
  has_many :authentications
  has_many :endpoints
  has_many :sources
  has_many :tags

  def self.tenancy_enabled?
    ENV["BYPASS_TENANCY"].blank?
  end
end

