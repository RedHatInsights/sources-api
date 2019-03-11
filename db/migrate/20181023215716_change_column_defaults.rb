class ChangeColumnDefaults < ActiveRecord::Migration[5.1]
  def change
    change_column_default :endpoints, :default, :from => nil, :to => false
  end
end
