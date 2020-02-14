class SourceTag < ApplicationRecord
  belongs_to :tenant
  belongs_to :source
  belongs_to :tag
end
