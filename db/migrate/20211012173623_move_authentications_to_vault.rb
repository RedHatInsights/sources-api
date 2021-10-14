class MoveAuthenticationsToVault < ActiveRecord::Migration[5.2]
  def up
    add_column :application_authentications, :vault_path, :string

    transaction do
      migrations, empty = Authentication.all.partition { |a| a.resource.present? }

      Rails.logger.warn("Skipping #{empty.count} authentications with no resource attached.")

      migrations.each do |auth|
        VaultInterface.new(auth).process
      end
    end
  end

  def down
    remove_column :application_authentications, :vault_path
  end
end
