class AddJsonSchemaToSourceTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :source_types, :schema, :jsonb
  end
end
