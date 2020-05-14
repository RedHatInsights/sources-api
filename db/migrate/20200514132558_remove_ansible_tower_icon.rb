class RemoveAnsibleTowerIcon < ActiveRecord::Migration[5.2]
  def change
    ansible_tower = SourceType.find_by(name: 'ansible-tower')
    ansible_tower.icon_url = nil
    ansible_tower.save
  end
end
