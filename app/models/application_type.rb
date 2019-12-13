class ApplicationType < ApplicationRecord
  include SeedingConcern
  self.seed_key = :name

  has_many :applications
  has_many :sources, :through => :applications
end
