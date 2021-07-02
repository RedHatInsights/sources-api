class AddPausedAtToEndpoints < ActiveRecord::Migration[5.2]
  def change
    add_column :endpoints, :paused_at, :datetime
    add_index :endpoints, :paused_at
  end
end
