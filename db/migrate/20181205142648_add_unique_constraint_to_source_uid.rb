class AddUniqueConstraintToSourceUid < ActiveRecord::Migration[5.1]
  def change
    add_index :sources, [:uid], :unique => true
    change_column_null :sources, :uid, false
  end
end
