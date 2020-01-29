class Tag < ApplicationRecord
  belongs_to :tenant

  has_many :authentication_tags
  has_many :authentications, :through => :authentication_tags

  has_many :endpoint_tags
  has_many :endpoints, :through => :endpoint_tags

  has_many :source_tags
  has_many :sources, :through => :source_tags
end
