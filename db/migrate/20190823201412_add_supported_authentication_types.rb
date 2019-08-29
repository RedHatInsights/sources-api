class AddSupportedAuthenticationTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :application_types, :supported_authentication_types, :jsonb
  end
end
