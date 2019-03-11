class AddDefaultToEndpoints < ActiveRecord::Migration[5.0]
  def change
    add_column :endpoints, :default, :boolean
  end
end
