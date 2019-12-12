def update_or_create(attributes)
  obj = ApplicationType.find_by(:name => attributes[:name])
  if obj
    obj.update!(attributes.except(:name))
  else
    ApplicationType.create!(attributes)
  end
end

update_or_create(
  :name                           => "/insights/platform/catalog",
  :display_name                   => "Catalog",
  :dependent_applications         => ["/insights/platform/topological-inventory"],
  :supported_source_types         => ["ansible-tower"],
  :supported_authentication_types => {"ansible-tower" => ["username_password"]}
)

update_or_create(
  :name                           => "/insights/platform/cost-management",
  :display_name                   => "Cost Management",
  :dependent_applications         => [],
  :supported_source_types         => ["amazon", "azure", "openshift"],
  :supported_authentication_types => {
    "amazon"    => ["arn"],
    "azure"     => ["tenant_id_client_id_client_secret"],
    "openshift" => ["token"]
  }
)

update_or_create(
  :name                           => "/insights/platform/topological-inventory",
  :display_name                   => "Topological Inventory",
  :dependent_applications         => [],
  :supported_source_types         => ["amazon", "ansible-tower", "azure", "openshift"],
  :supported_authentication_types => {
    "amazon"        => ["access_key_secret_key"],
    "ansible-tower" => ["username_password"],
    "azure"         => ["tenant_id_client_id_client_secret"],
    "openshift"     => ["token"]
  }
)

update_or_create(
  :name                           => "/insights/platform/fifi",
  :display_name                   => "Find It Fix It",
  :dependent_applications         => [],
  :supported_source_types         => ["satellite"],
  :supported_authentication_types => {
    "satellite" => ["receptor_node"]
  }
)
