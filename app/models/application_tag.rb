class ApplicationTag < ApplicationRecord
  belongs_to :application
  belongs_to :tag
end
