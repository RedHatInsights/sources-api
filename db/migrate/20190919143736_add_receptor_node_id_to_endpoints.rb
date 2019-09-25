class AddReceptorNodeIdToEndpoints < ActiveRecord::Migration[5.2]
  def change
    add_column :endpoints, :receptor_node, :string
  end
end
