class CreateMetaData < ActiveRecord::Migration[5.2]
  def change
    create_table :meta_data do |t|
      t.integer :application_type_id
      t.integer :step
      t.string :name
      t.jsonb :payload
      t.jsonb :substitutions

      t.timestamps
    end
  end
end
