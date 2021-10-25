class AddSourceTypeToMetaData < ActiveRecord::Migration[5.2]
  def change
    add_column :meta_data, :source_type_id, :integer
  end
end
