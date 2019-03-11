class AddSourcesAndEndpoints < ActiveRecord::Migration[5.0]
  def change
    create_table :sources, :id => :bigserial do |t|
      t.string :name
      t.string :uid
      t.timestamps
    end

    create_table :endpoints, :id => :bigserial do |t|
      t.string     :role
      t.string     :ipaddress
      t.string     :ipv6address
      t.string     :hostname
      t.integer    :port
      t.references :source, :type => :bigint
      t.timestamps
    end
  end
end
