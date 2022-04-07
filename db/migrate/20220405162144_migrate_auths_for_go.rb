class MigrateAuthsForGo < ActiveRecord::Migration[5.2]
  def up
    add_column :authentications, :password_hash, :string

    Authentication.where.not(:password => nil).where.not(:password => "").each do |auth|
      if auth.resource.nil?
        Rails.logger.warn("skipping auth #{auth.id} due to resource not existing")
        next
      end

      auth.update!(:password_hash => GoEncryption.encrypt(auth.password))
    end
  end

  def down
    remove_column :authentications, :password_hash, :string
  end
end