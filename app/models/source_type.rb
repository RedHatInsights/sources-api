class SourceType < ApplicationRecord
  include SeedingConcern
  self.seed_key = :name

  has_many :sources

  def superkey_authtype
    return nil unless schema

    schema.fetch("authentication", [])
          .detect { |auth| auth["is_superkey"] == true }
          .try(:[], "type")
  end
end
