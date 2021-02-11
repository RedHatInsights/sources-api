class AddSuperkeyDataToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :superkey_data, :jsonb
  end
end
