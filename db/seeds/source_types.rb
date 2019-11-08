def update_or_create(attributes)
  obj = SourceType.find_by(:name => attributes[:name])
  if obj
    obj.update!(attributes.except(:name))
  else
    SourceType.create!(attributes)
  end
end

openshift_json_schema = {
  :authentication => [{
    :type   => 'token',
    :name   => "Token",
    :fields => [
      {:component => "text-field", :name => "authentication.authtype", :hideField => true, :initialValue => "token"},
      {:component => "text-field", :name => "authentication.password", :label => "Token", :type => "password"}
    ]
  }],
  :endpoint       => {
    :title  => "Configure OpenShift endpoint",
    :fields => [
      {:component => "text-field", :name => "endpoint.role", :hideField => true, :initialValue => "kubernetes"},
      {:component => "text-field", :name => "url", :label => "URL", :validate => [{:type => "url-validator"}]},
      {:component => "switch-field", :name => "endpoint.verify_ssl", :label => "Verify SSL"},
      {:component => "text-field", :name => "endpoint.certificate_authority", :label => "Certificate Authority", :condition => {:when => "endpoint.verify_ssl", :is => true}}
    ]
  }
}

update_or_create(
  :name         => "openshift",
  :product_name => "OpenShift Container Platform",
  :schema       => openshift_json_schema,
  :vendor       => "Red Hat",
  :icon_url     => "/openshift_logo.png"
)

amazon_json_schema = {
  :authentication => [{
    :type   => 'access_key_secret_key',
    :name   => "AWS Secret Key",
    :fields => [
      {:component => "text-field", :name => "authentication.authtype", :hideField => true, :initialValue => "access_key_secret_key"},
      {:component => "text-field", :name => "authentication.username", :label => "Access Key"},
      {:component => "text-field", :name => "authentication.password", :label => "Secret Key", :type => "password"}
    ]
  }, {
    :type   => 'arn',
    :name   => 'ARN',
    :fields => [{
      :component    => 'text-field',
      :name         => 'authentication.authtype',
      :hideField    => true,
      :initialValue => 'arn'
    }, {
      :name       => 'billing_source.bucket',
      :stepKey    => 'amazon-arn-additional-step',
      :component  => 'text-field',
      :label      => 'S3 bucket name',
      :isRequired => true,
      :validate   => [
        { :type=>  'required-validator' },
        { :type => 'pattern-validator', :pattern => '^[A-Za-z0-9]+[A-Za-z0-9_-]*$' }
      ]
    }, {
      :name       => 'authentication.password',
      :stepKey    => 'arn',
      :component  => 'text-field',
      :label      => 'ARN',
      :isRequired => true,
      :validate   => [
        { :type => 'required-validator' },
        { :type => 'pattern-validator', :pattern => '^arn:aws:.*' },
        { :type => 'min-length-validator', :threshold => 10 }
      ]
    }],
  }],
  :endpoint       => {
    :hidden => true,
    :fields => [
      {:component => "text-field", :name => "endpoint.role", :hideField => true, :initialValue => "aws"},
    ]
  }
}

update_or_create(
  :name         => "amazon",
  :product_name => "Amazon Web Services",
  :schema       => amazon_json_schema,
  :vendor       => "Amazon",
  :icon_url     => "/aws_logo.png"
)

azure_json_schema = {
  :authentication => [{
    :type   => 'tenant_id_client_id_client_secret',
    :name   => "Tenant ID, Client ID, Client Secret",
    :fields => [
      {:component => "text-field", :name => "authentication.authtype", :hideField => true, :initialValue => "tenant_id_client_id_client_secret"},
      {:component => "text-field", :name => "authentication.extra.azure.tenant_id", :label => "Tenant ID"},
      {:component => "text-field", :name => "authentication.username", :label => "Client ID"},
      {:component => "text-field", :name => "authentication.password", :label => "Client Secret", :type => "password"}
    ]
  }],
  :endpoint       => {
    :hidden => true,
    :fields => [
      {:component => "text-field", :name => "endpoint.role", :hideField => true, :initialValue => "azure"},
    ]
  }
}

update_or_create(:name => "azure", :product_name => "Microsoft Azure", :vendor => "Azure", :schema => azure_json_schema)

ansible_tower_json_schema = {
  :authentication => [{
    :type   => "username_password",
    :name   => "Username and password",
    :fields => [
      {:component => "text-field", :name => "authentication.authtype", :hideField => true, :initialValue => "username_password"},
      {:component => "text-field", :name => "authentication.username", :label => "User name"},
      {:component => "text-field", :name => "authentication.password", :label => "Secret Key", :type => "password"}
    ]
  }],
  :endpoint       => {
    :title  => "Configure Ansible Tower endpoint",
    :fields => [
      {:component => "text-field", :name => "endpoint.role", :hideField => true, :initialValue => "ansible"},
      {:component => "text-field", :name => "url", :label => "URL", :validate => [{:type => "url-validator"}]},
      {:component => "switch-field", :name => "endpoint.verify_ssl", :label => "Verify SSL"},
      {:component => "text-field", :name => "endpoint.certificate_authority", :label => "Certificate Authority", :condition => {:when => "endpoint.verify_ssl", :is => true}},
    ]
  }
}

update_or_create(:name => "ansible-tower", :product_name => "Ansible Tower", :vendor => "Red Hat", :schema => ansible_tower_json_schema)
update_or_create(:name => "vsphere", :product_name => "VMware vSphere", :vendor => "VMware", :icon_url => "/vsphere_logo.png")
update_or_create(:name => "ovirt", :product_name => "Red Hat Virtualization", :vendor => "Red Hat")
update_or_create(:name => "openstack", :product_name => "Red Hat OpenStack", :vendor => "Red Hat")
update_or_create(:name => "cloudforms", :product_name => "Red Hat CloudForms", :vendor => "Red Hat")
update_or_create(:name => "satellite", :product_name => "Red Hat Satellite", :vendor => "Red Hat")
