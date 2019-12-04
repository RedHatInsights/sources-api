class AddAvailabilityCheckUrlToApplicationTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :application_types, :availability_check_url, :string
  end
end
