class ChangeSourcesSourceTypeToNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null(:sources, :source_type_id, false)
  end
end
