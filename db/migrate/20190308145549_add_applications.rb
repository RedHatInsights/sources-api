class AddApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :applications do |t|
      t.references :tenant,           :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.references :source,           :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.references :application_type, :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.timestamps
    end
  end
end
