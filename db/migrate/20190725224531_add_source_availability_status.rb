class AddSourceAvailabilityStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :availability_status, :string
  end
end
