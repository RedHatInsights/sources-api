def update_or_create(attributes)
  obj = ApplicationType.find_by(:name => attributes[:name])
  if obj
    obj.update_attributes!(attributes.except(:name))
  else
    ApplicationType.create!(attributes)
  end
end

update_or_create(
  :name                           => "/insights/platform/catalog",
  :display_name                   => "Catalog",
  :dependent_applications         => ["/insights/platform/topological-inventory"],
  :supported_source_types         => ["ansible_tower"],
  :supported_authentication_types => {"ansible_tower" => ["username_password"]})

update_or_create(
  :name                           => "/insights/platform/cost-management",
  :display_name                   => "Cost Management",
  :dependent_applications         => [],
  :supported_source_types         => ["amazon"],
  :supported_authentication_types => {"amazon" => ["arn"]})

update_or_create(
  :name                           => "/insights/platform/topological-inventory",
  :display_name                   => "Topological Inventory",
  :dependent_applications         => [],
  :supported_source_types         => ["amazon", "ansible_tower", "azure", "openshift"],
  :supported_authentication_types => {
    "amazon"        => ["access_key_secret_key"],
    "ansible_tower" => ["username_password"],
    "azure"         => ["username_password"],
    "openshift"     => ["token"]
  }
)
