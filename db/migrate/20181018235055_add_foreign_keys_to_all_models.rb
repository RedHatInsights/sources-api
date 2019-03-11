class AddForeignKeysToAllModels < ActiveRecord::Migration[5.1]
  def change
    # On delete cascade
    add_foreign_key :endpoints,       :sources, on_delete: :cascade
    add_foreign_key :endpoints,       :tenants, on_delete: :cascade
    add_foreign_key :sources,         :tenants, on_delete: :cascade
    add_foreign_key :authentications, :tenants, on_delete: :cascade
  end
end
