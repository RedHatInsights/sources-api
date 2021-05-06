class AddPausedAtColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :paused_at, :datetime
    add_index :sources, :paused_at

    add_column :applications, :paused_at, :datetime
    add_index :applications, :paused_at

    add_column :authentications, :paused_at, :datetime
    add_index :authentications, :paused_at

    add_column :application_authentications, :paused_at, :datetime
    add_index :application_authentications, :paused_at
  end
end
