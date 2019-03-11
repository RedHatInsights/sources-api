class RenameAuthenticationUseridToUsername < ActiveRecord::Migration[5.2]
  def change
    rename_column :authentications, :userid, :username
  end
end
