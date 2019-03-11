class AddSslOptionsToEndpoints < ActiveRecord::Migration[5.1]
  def change
    add_column :endpoints, :verify_ssl,            :boolean
    add_column :endpoints, :certificate_authority, :text
  end
end
