class AddAuthentications < ActiveRecord::Migration[5.0]
  def change
    create_table :authentications, :id => :bigserial do |t|
      t.references "resource", :polymorphic => true, :index => true
      t.string     "name"
      t.string     "authtype"
      t.string     "userid"
      t.string     "password"
      t.string     "status"
      t.string     "status_details"
    end
  end
end
