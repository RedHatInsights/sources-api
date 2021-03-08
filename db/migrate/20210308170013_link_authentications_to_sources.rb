class LinkAuthenticationsToSources < ActiveRecord::Migration[5.2]
  def change
    Authentication.where(:source_id => nil).each do |auth|
      parent = auth.resource_type.constantize.send(:find, auth.resource_id)

      Rails.logger.info("Linking Authentication #{auth.id} to #{resource_type} #{resource_id}'s parent Source")
      auth.update!(:source_id => parent.source_id)
    rescue => e
      Rails.logger.warn("Error trying to find parent for Authentication #{auth.id}: #{e}")
    end
  end
end
