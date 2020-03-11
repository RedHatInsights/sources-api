class AddApplicationAuthentications < ActiveRecord::Migration[5.2]
  def change
    create_table :application_authentications do |t|
      t.references :tenant,         :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.references :application,    :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.references :authentication, :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.timestamps
      t.index %w[tenant_id application_id authentication_id], :unique => true, :name => "index_on_tenant_application_authentication"
    end
  end
end
