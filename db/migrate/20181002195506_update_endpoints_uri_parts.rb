class UpdateEndpointsUriParts < ActiveRecord::Migration[5.0]
  def change
    remove_column :endpoints, :ipaddress, :string
    remove_column :endpoints, :ipv6address, :string
    remove_column :endpoints, :hostname, :string
    add_column    :endpoints, :scheme, :string
    add_column    :endpoints, :host, :string
    add_column    :endpoints, :path, :string
  end
end
