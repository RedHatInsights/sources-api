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
    {:component => "text-field", :name => "authtype", :type => "hidden", :initialValue => "token"},
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
    {:component => "text-field", :name => "authtype", :type => "hidden", :initialValue => "access_key_secret_key"},
    {:component => "text-field", :name => "username", :label => "Access Key"},
    {:component => "text-field", :name => "password", :label => "Secret Key", :type => "password"}
  ]
}
update_or_create(SourceType, :name => "amazon", :product_name => "Amazon Web Services", :vendor => "Amazon", :schema => amazon_json_schema)

azure_json_schema = {
  :title  => "Configure Azure",
  :fields => [
    {:component => "text-field", :name => "role", :type => "hidden", :initialValue => "azure"},
    {:component => "text-field", :name => "authtype", :type => "hidden", :initialValue => "access_key_secret_key"},
    {:component => "text-field", :name => "extra.azure.tenant_id", :label => "Tenant ID"},
    {:component => "text-field", :name => "username", :label => "Client ID"},
    {:component => "text-field", :name => "password", :label => "Client Secret", :type => "password"}
  ]
}
update_or_create(SourceType, :name => "azure", :product_name => "Microsoft Azure", :vendor => "Azure", :schema => azure_json_schema)

ansible_tower_json_schema = {
  :title  => "Configure AnsibleTower",
  :fields => [
    {:component => "text-field", :name => "role", :type => "hidden", :initialValue => "ansible"}, # FIXME: Find the correct value.
    {:component => "text-field", :name => "authtype", :type => "hidden", :initialValue => "username_password"},
    {:component => "text-field", :name => "url", :label => "URL"},
    {:component => "checkbox", :name => "verify_ssl", :label => "Verify SSL"},
    {:component => "text-field", :name => "certificate_authority", :label => "Certificate Authority", :condition => {:when => "verify_ssl", :is => true}},
    {:component => "text-field", :name => "username", :label => "User name"},
    {:component => "text-field", :name => "password", :label => "Secret Key", :type => "password"}
  ]
}
update_or_create(SourceType, :name => "ansible-tower", :product_name => "Ansible Tower", :vendor => "Red Hat", :schema => ansible_tower_json_schema)
update_or_create(SourceType, :name => "vsphere", :product_name => "VMware vSphere", :vendor => "VMware")
update_or_create(SourceType, :name => "ovirt", :product_name => "Red Hat Virtualization", :vendor => "Red Hat")
update_or_create(SourceType, :name => "openstack", :product_name => "Red Hat OpenStack", :vendor => "Red Hat")
update_or_create(SourceType, :name => "cloudforms", :product_name => "Red Hat CloudForms", :vendor => "Red Hat")

update_or_create(ApplicationType,
                 :name                           => "/insights/platform/catalog",
                 :display_name                   => "Catalog",
                 :dependent_applications         => ["/insights/platform/topological-inventory"],
                 :supported_source_types         => ["ansible_tower"],
                 :supported_authentication_types => {"ansible_tower" => ["username_password"]})

update_or_create(ApplicationType,
                 :name                           => "/insights/platform/cost-management",
                 :display_name                   => "Cost Management",
                 :dependent_applications         => [],
                 :supported_source_types         => ["amazon"],
                 :supported_authentication_types => {"amazon" => ["arn"]})

update_or_create(ApplicationType,
                 :name                           => "/insights/platform/topological-inventory",
                 :display_name                   => "Topological Inventory",
                 :dependent_applications         => [],
                 :supported_source_types         => ["amazon", "ansible_tower", "azure", "openshift"],
                 :supported_authentication_types => {
                   "amazon"        => ["access_key_secret_key"],
                   "ansible_tower" => ["username_password"],
                   "azure"         => ["username_password"],
                   "openshift"     => ["token"]
                 })
