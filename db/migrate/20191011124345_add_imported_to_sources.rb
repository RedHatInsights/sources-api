class AddImportedToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :imported, :string
  end
end
