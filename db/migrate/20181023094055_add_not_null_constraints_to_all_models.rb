class AddNotNullConstraintsToAllModels < ActiveRecord::Migration[5.1]
  def up
    change_column :endpoints,           :tenant_id, :bigint, :null => false
    change_column :sources,             :tenant_id, :bigint, :null => false
    change_column :authentications,     :tenant_id, :bigint, :null => false
  end
  
  def down
    change_column :endpoints,           :tenant_id, :bigint, :null => true
    change_column :sources,             :tenant_id, :bigint, :null => true
    change_column :authentications,     :tenant_id, :bigint, :null => true
  end
end
