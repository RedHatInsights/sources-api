class ChangeSourcesNameToNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null(:sources, :name, false, "")
  end
end
