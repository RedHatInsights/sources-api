class Availability < ApplicationRecord
  belongs_to :resource, :polymorphic => true
end
