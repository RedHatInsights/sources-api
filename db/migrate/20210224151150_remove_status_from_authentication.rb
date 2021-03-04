class RemoveStatusFromAuthentication < ActiveRecord::Migration[5.2]
  def change
    remove_column :authentications, :status,         :string
    remove_column :authentications, :status_details, :string
  end
end
