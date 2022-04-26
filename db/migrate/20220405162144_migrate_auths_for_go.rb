class MigrateAuthsForGo < ActiveRecord::Migration[5.2]
  def up
    add_column :authentications, :password_hash, :string

    Authentication.where.not(:password => nil).where.not(:password => "").each do |auth|
      if auth.resource.nil?
        Rails.logger.warn("skipping auth #{auth.id} due to resource not existing")
        next
      end

      if auth.password.blank?
        Rails.logger.warn("skipping auth #{auth.id} due to password being blank")
        next
      end

      begin
        auth.update!(:password_hash => GoEncryption.encrypt(auth.password))
      rescue => e
        Rails.logger.warn("Error encrypting password for authentication id: #{auth.id}")
        raise
      end
    end
  end

  def down
    remove_column :authentications, :password_hash, :string
  end
end
