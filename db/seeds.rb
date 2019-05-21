def update_or_create(model, attributes)
  obj = model.find_by(:name => attributes[:name])
  if obj
    obj.update_attributes!(attributes.except(:name))
  else
    model.create!(attributes)
  end
end

openshift_json_schema = {
  :title  => "Configure OpenShift",
  :fields => [
    {:component => "text-field", :name => "role", :type => "hidden", :initialValue => "kubernetes"},
    {:component => "text-field", :name => "auth_type", :type => "hidden", :initialValue => "token"},
    {:component => "text-field", :name => "url", :label => "URL"},
    {:component => "checkbox", :name => "verify_ssl", :label => "Verify SSL"},
    {:component => "text-field", :name => "certificate_authority", :label => "Certificate Authority", :condition => {:when => "verify_ssl", :is => true}},
    {:component => "text-field", :name => "token", :label => "Token", :type => "password"}
  ]
}
update_or_create(SourceType, :name => "openshift", :product_name => "OpenShift Container Platform", :vendor => "Red Hat", :schema => openshift_json_schema)

amazon_json_schema = {
  :title  => "Configure AWS",
  :fields => [
    {:component => "text-field", :name => "role", :type => "hidden", :initialValue => "aws"},
    {:component => "text-field", :name => "auth_type", :type => "hidden", :initialValue => "access_key_secret_key"},
    {:component => "text-field", :name => "user_name", :label => "Access Key"},
    {:component => "text-field", :name => "password", :label => "Secret Key", :type => "password"}
  ]
}
update_or_create(SourceType, :name => "amazon", :product_name => "Amazon Web Services", :vendor => "Amazon", :schema => amazon_json_schema)

ansible_tower_json_schema = {
  :title  => "Configure AnsibleTower",
  :fields => [
    {:component => "text-field", :name => "role", :type => "hidden", :initialValue => "ansible"}, # FIXME: Find the correct value.
    {:component => "text-field", :name => "auth_type", :type => "hidden", :initialValue => "username_password"},
    {:component => "text-field", :name => "url", :label => "URL"},
    {:component => "checkbox", :name => "verify_ssl", :label => "Verify SSL"},
    {:component => "text-field", :name => "certificate_authority", :label => "Certificate Authority", :condition => {:when => "verify_ssl", :is => true}},
    {:component => "text-field", :name => "user", :label => "User name"},
    {:component => "text-field", :name => "password", :label => "Secret Key", :type => "password"}
  ]
}
update_or_create(SourceType, :name => "ansible-tower", :product_name => "Ansible Tower", :vendor => "Red Hat", :schema => ansible_tower_json_schema)

update_or_create(ApplicationType, :name => "/insights/platform/catalog",               :display_name => "Catalog")
update_or_create(ApplicationType, :name => "/insights/platform/cost-management",       :display_name => "Cost Management")
update_or_create(ApplicationType, :name => "/insights/platform/topological-inventory", :display_name => "Topological Inventory")
