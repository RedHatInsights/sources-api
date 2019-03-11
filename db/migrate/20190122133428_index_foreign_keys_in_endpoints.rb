class IndexForeignKeysInEndpoints < ActiveRecord::Migration[5.2]
  def change
    add_index :endpoints, :tenant_id
  end
end
