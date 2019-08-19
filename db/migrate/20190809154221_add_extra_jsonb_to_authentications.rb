class AddExtraJsonbToAuthentications < ActiveRecord::Migration[5.2]
  def change
    add_column :authentications, :extra, :jsonb
  end
end
