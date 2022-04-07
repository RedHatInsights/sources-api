class MigrateAuthsForGo < ActiveRecord::Migration[5.2]
  def up
    add_column :authentications, :password_hash, :string

    Authentication.where.not(:password => nil).where.not(:password => "").each do |auth|
      auth.update!(:password_hash => GoEncryption.encrypt(auth.password))
    end
  end

  def down
    remove_column :authentications, :password_hash, :string
  end
end
