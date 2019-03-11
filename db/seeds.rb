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
    {:component => "text-field", :name => "url", :label => "URL"},
    {:component => "checkbox", :name => "verify_ssl", :label => "Verify SSL"},
    {:component => "text-field", :name => "certificate_authority", :label => "Certificate Authority", :condition => {:when => "verify_ssl", :is => true}},
    {:component => "textarea-field", :name => "token", :label => "Token"}
  ]
}
update_or_create(SourceType, :name => "openshift", :product_name => "OpenShift", :vendor => "Red Hat", :schema => openshift_json_schema)

amazon_json_schema = {
  :title  => "Configure AWS",
  :fields => [
    {:component => "text-field", :name => "user_name", :label => "Access Key"},
    {:component => "text-field", :name => "password", :label => "Secret Key"}
  ]
}
update_or_create(SourceType, :name => "amazon", :product_name => "AWS", :vendor => "Amazon", :schema => amazon_json_schema)
