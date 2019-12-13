class SourceType < ApplicationRecord
  include SeedingConcern
  self.seed_key = :name

  has_many :sources
end
