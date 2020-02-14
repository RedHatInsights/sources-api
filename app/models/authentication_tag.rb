class AuthenticationTag < ApplicationRecord
  belongs_to :tenant
  belongs_to :authentication
  belongs_to :tag
end
