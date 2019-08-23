class AddDependentApplicationsToApplicationTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :application_types, :dependent_applications, :jsonb
  end
end
