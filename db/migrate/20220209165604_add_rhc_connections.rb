class AddRhcConnections < ActiveRecord::Migration[5.2]
  def up
    create_table :rhc_connections do |t|
      t.string :rhc_id
      t.jsonb :extra, :default => '{}'
      t.string :availability_status
      t.string :availability_status_error
      t.datetime :last_checked_at
      t.datetime :last_available_at

      t.timestamps
    end

    create_table :source_rhc_connections, :id => false do |t|
      t.integer :source_id
      t.integer :rhc_connection_id
    end

    add_index :rhc_connections, :rhc_id, :unique => true
    add_index :source_rhc_connections, [:source_id, :rhc_connection_id], :unique => true
  end

  def down
    drop_table :rhc_connections
    drop_table :source_rhc_connections
  end
end
