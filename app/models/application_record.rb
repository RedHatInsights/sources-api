class ApplicationRecord < ActiveRecord::Base
  require 'acts_as_tenant'

  self.abstract_class = true

  def as_json(options = {})
    options[:except] ||= []
    super
  end
end
