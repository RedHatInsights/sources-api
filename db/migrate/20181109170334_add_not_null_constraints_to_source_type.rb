class AddNotNullConstraintsToSourceType < ActiveRecord::Migration[5.1]
  def up
    change_column :source_types, :name,         :string, :null => false
    change_column :source_types, :product_name, :string, :null => false
    change_column :source_types, :vendor,       :string, :null => false
  end
end
