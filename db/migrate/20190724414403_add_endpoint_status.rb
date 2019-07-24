class AddEndpointStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :endpoints, :status, :string
  end
end
