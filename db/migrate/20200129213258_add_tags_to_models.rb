class AddTagsToModels < ActiveRecord::Migration[5.2]
  def change
    create_table "authentication_tags" do |t|
      t.references "tenant", :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.references "tag", :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.string "value", :null => false, :default => ""
      t.references "authentication", :index => false, :null => false, :foreign_key => {:on_delete => :cascade}
      t.index %w[authentication_id tag_id value], :unique => true, :name => "uniq_index_on_authentication_id_tag_id_value"
    end
    create_table "endpoint_tags" do |t|
      t.references "tenant", :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.references "tag", :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.string "value", :null => false, :default => ""
      t.references "endpoint", :index => false, :null => false, :foreign_key => {:on_delete => :cascade}
      t.index %w[endpoint_id tag_id value], :unique => true, :name => "uniq_index_on_endpoint_id_tag_id_value"
    end
    create_table "source_tags" do |t|
      t.references "tenant", :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.references "tag", :index => true, :null => false, :foreign_key => {:on_delete => :cascade}
      t.string "value", :null => false, :default => ""
      t.references "source", :index => false, :null => false, :foreign_key => {:on_delete => :cascade}
      t.index %w[source_id tag_id value], :unique => true, :name => "uniq_index_on_source_id_tag_id_value"
    end
  end
end
