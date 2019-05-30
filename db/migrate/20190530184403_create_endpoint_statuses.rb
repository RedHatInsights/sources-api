class CreateEndpointStatuses < ActiveRecord::Migration[5.2]
  def change
    create_enum "endpoint_status", %w[unknown available unavailable supported unsupported]

    create_table :endpoint_statuses, :id => :bigserial do |t|
      t.string   :type, :null => false
      t.string   :reason
      t.column   :status, :endpoint_status
      t.datetime :last_checked_at
      t.datetime :last_valid_at
      t.bigint   :endpoint_id

      t.timestamps
    end

    add_foreign_key :endpoint_statuses, :endpoints, :on_delete => :cascade
    add_reference :endpoints, :endpoint_availability, :index => true, :foreign_key => {:on_delete => :cascade, :to_table => :endpoint_statuses}
  end
end

