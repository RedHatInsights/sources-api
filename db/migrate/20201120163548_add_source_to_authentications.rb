class AddSourceToAuthentications < ActiveRecord::Migration[5.2]
  def up
    add_column :authentications, :source_id, :bigint
    Authentication.transaction do
      Authentication.find_each do |auth|
        # apparently we have some dangling endpoints/applications, so we need to skip them.
        next unless auth.resource&.source_id

        auth.update!(:source_id => auth.resource.source_id)
      end
    end
  end

  def down
    remove_column :authentications, :source_id
  end
end
