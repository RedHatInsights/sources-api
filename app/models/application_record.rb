class ApplicationRecord < ActiveRecord::Base
  require 'acts_as_tenant'

  self.abstract_class = true

  def as_json(options = {})
    options[:except] ||= []
    super
  end

  require 'act_as_taggable_on'
  ActiveSupport.on_load(:active_record) do
    extend ActAsTaggableOn
  end
end
