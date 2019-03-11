class IndexForeignKeysInAuthentications < ActiveRecord::Migration[5.2]
  def change
    add_index :authentications, :tenant_id
  end
end
