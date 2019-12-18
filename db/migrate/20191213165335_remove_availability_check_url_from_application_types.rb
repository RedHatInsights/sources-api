class RemoveAvailabilityCheckUrlFromApplicationTypes < ActiveRecord::Migration[5.2]
  def change
    remove_column :application_types, :availability_check_url, :string
  end
end
