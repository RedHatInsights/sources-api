class ApplicationType < ApplicationRecord
  include SeedingConcern
  self.seed_key = :name

  has_many :applications
  has_many :sources, :through => :applications
  has_many :app_meta_data, :dependent => :destroy, :class_name => "AppMetaData"
  has_many :super_key_meta_data, :dependent => :destroy, :class_name => "SuperKeyMetaData"
end
