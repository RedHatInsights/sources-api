class AddVersionToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :version, :string
  end
end
