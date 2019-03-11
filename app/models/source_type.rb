class SourceType < ApplicationRecord
  has_many :sources
  has_many :availabilities, :as => :resource, :dependent => :destroy, :inverse_of => :resource
end
