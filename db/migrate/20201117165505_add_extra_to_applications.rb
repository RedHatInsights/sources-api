class AddExtraToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :extra, :jsonb, :default => {}
  end
end
