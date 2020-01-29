class AuthenticationTag < ApplicationRecord
  belongs_to :authentication
  belongs_to :tag
end
