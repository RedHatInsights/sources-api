class AddSupportedSourceTypesToApplicationTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :application_types, :supported_source_types, :jsonb
  end
end
