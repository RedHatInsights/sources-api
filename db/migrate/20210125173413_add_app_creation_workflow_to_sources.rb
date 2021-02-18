class AddAppCreationWorkflowToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :app_creation_workflow, :string, :default => "manual_configuration"
  end
end
