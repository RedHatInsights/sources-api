class Tenant < ApplicationRecord
  has_many :authentications
  has_many :endpoints
  has_many :sources

  def self.tenancy_enabled?
    ENV["BYPASS_TENANCY"].blank?
  end
end

