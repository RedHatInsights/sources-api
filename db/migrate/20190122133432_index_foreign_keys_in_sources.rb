class IndexForeignKeysInSources < ActiveRecord::Migration[5.2]
  def change
    add_index :sources, :tenant_id
  end
end
