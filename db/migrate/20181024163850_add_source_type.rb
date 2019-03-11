class AddSourceType < ActiveRecord::Migration[5.1]
  def change
    create_table :source_types, :id => :bigserial do |t|
      t.string :name
      t.string :product_name
      t.string :vendor
      t.timestamps
      t.index :name, :unique => true
    end

    add_reference :sources, :source_type,  :index => true, :foreign_key => {:on_delete => :cascade}
  end
end
