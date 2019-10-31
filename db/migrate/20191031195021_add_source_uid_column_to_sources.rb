class AddSourceUidColumnToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :source_uid, :string
  end
end
