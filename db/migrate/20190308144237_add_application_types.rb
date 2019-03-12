class AddApplicationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :application_types do |t|
      t.string :name, :null => false
      t.index %w[name], :unique => true
      t.timestamps
    end
  end
end
