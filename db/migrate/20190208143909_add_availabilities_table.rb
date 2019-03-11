class AddAvailabilitiesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :availabilities, :id => :bigserial, :force => :cascade do |t|
      t.references :resource,     :polymorphic => true, :index => false, :null => false
      t.string     :action,       :null => false
      t.string     :identifier,   :null => false
      t.string     :availability, :null => false
      t.datetime   :last_checked_at
      t.datetime   :last_valid_at
      t.timestamps
      t.index      [:resource_type, :resource_id, :action, :identifier], :unique => true,
                   :name => :index_on_resource_action_identifier
    end
  end
end
