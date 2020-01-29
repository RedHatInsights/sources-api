class AddTags < ActiveRecord::Migration[5.2]
  def change
    create_table "tags" do |t|
      t.references "tenant", :index => false, :null => false, :foreign_key => {:on_delete => :cascade}
      t.string "name", :null => false
      t.string "namespace", :default => "", :null => false
      t.text "description"
      t.index %w[tenant_id namespace name], :unique => true
    end
  end
end
