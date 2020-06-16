class AddLastCheckedAtAndLastAvailableAtToSource < ActiveRecord::Migration[5.2]
  def change
    %i[last_checked_at last_available_at].each do |col|
      add_column :sources, col, :timestamp
      add_column :endpoints, col, :timestamp
      add_column :authentications, col, :timestamp
      add_column :applications, col, :timestamp
    end
  end
end
