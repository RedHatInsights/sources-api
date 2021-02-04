# :type was apparently dropped during one of my rebases.
# Not sure why but we definitely need it.
class AddTypeToMetaData < ActiveRecord::Migration[5.2]
  def change
    add_column :meta_data, :type, :string
  end
end
