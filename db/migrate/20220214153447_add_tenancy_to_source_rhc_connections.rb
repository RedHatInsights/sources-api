class AddTenancyToSourceRhcConnections < ActiveRecord::Migration[5.2]
  def up
    add_column :source_rhc_connections, :tenant_id, :bigint

    add_foreign_key(:source_rhc_connections, :sources, :name => "fk_source_id", :on_delete => :cascade)
    add_foreign_key(:source_rhc_connections, :rhc_connections, :name => "fk_rhc_connection_id", :on_delete => :cascade)
    add_foreign_key(:source_rhc_connections, :tenants, :name => "fk_tenant_id")

    change_column_default(:rhc_connections, :extra, {})
  end

  def down
    remove_foreign_key(:source_rhc_connections, :name => "fk_source_id")
    remove_foreign_key(:source_rhc_connections, :name => "fk_rhc_connection_id")
    remove_foreign_key(:source_rhc_connections, :name => "fk_tenant_id")

    remove_column :source_rhc_connections, :tenant_id
  end
end
