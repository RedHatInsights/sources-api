class ApplicationType < ApplicationRecord
  has_many :applications
  has_many :sources, :through => :applications
end
