class AddAvailablilityStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :applications,    :availability_status,       :string
    add_column :applications,    :availability_status_error, :string
    add_column :authentications, :availability_status,       :string
    add_column :authentications, :availability_status_error, :string
    add_column :endpoints,       :availability_status,       :string
    add_column :endpoints,       :availability_status_error, :string
  end
end
