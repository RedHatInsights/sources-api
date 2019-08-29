class AddIconUrlToSourceTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :source_types, :icon_url, :string
  end
end
