RSpec.shared_examples_for "updating paused resource" do |model_klass|
  let(:origin_values) do
    {'name'                      => "Origin Name",
     'certificate_authority'     => "Origin Auth",
     'extra'                     => { "azure" => {"tenant_id" => "1" }},
     'availability_status'       => "available",
     'availability_status_error' => nil,
     'last_checked_at'           => nil,
     'last_available_at'         => nil
    }
  end

  let(:new_values_for_disallowed_attributes) do
    {'name'                  => "New Name",
     'certificate_authority' => "New Auth",
     'extra'                 => { "azure" => { "tenant_id" => "3" }},
    }
  end

  let(:new_values_for_allowed_attributes) do
    {
      'availability_status'       => "unavailable",
      'availability_status_error' => "error",
      'last_checked_at'           => Time.parse("03-03-2021 18:00"),
      'last_available_at'         => Time.parse("03-03-2021 19:00")
    }
  end

  def instance_attributes_for(model, mock_values)
    model_attributes = model.attribute_names & origin_values.keys
    mock_values.slice(*model_attributes)
  end

  let(:application) { create(:application, :tenant => tenant) }

  let(:authentication_payload) do
    {
      "username"      => "test_name",
      "password"      => "Test Password",
      "resource_type" => "Application",
      "resource_id"   => application.id.to_s
    }
  end

  let(:instance) do
    instance_attributes = instance_attributes_for(model_klass, origin_values)
    instance_attributes.merge!(authentication_payload) if model_klass == Authentication
    create(model_klass.name.tableize.singularize, instance_attributes.merge(:tenant => tenant))
  end

  before do
    instance.discard
  end

  it "rejects update action of disallowed attributes by pausing a #{model_klass}" do
    stub_const("ENV", "BYPASS_RBAC" => "true")
    new_attributes = instance_attributes_for(model_klass, new_values_for_disallowed_attributes)

    patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

    response_message = "Found unpermitted parameters: #{new_attributes.keys.sort.join(', ')}"
    expected_parsed_body = {"errors" => [{"detail" => response_message, "status" => "422"}]}
    expect(response).to have_attributes(:status => 422, :parsed_body => expected_parsed_body)

    instance.reload

    instance_attributes = instance.attributes
    instance_attributes_for(model_klass, origin_values).each do |key, value|
      expect(instance_attributes[key]).to eq(value)
    end
  end

  it "rejects update action of disallowed attributes by pausing a #{model_klass} and updates allowed attributes" do
    stub_const("ENV", "BYPASS_RBAC" => "true")
    update_attributes = new_values_for_disallowed_attributes.merge(new_values_for_allowed_attributes)
    new_attributes = instance_attributes_for(model_klass, update_attributes)

    patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

    response_message = "Listed parameters in 'resource' has been updated successfully."
    resource_parameters = instance_attributes_for(model_klass, new_values_for_allowed_attributes)
    result = {'detail' => response_message, 'resource' => resource_parameters, 'status' => 200}
    unpermitted_parameters = new_attributes.except(*new_values_for_allowed_attributes.keys)
    expected_parsed_body = {"results"=> [result], "errors" => [{"detail"=>"Found unpermitted parameters: #{unpermitted_parameters.keys.sort.join(', ')}", "status" => 422}]}

    expect(response).to have_attributes(:status => 207, :parsed_body => expected_parsed_body)

    instance.reload

    instance_attributes = instance.attributes
    instance_attributes_for(model_klass, origin_values.merge(new_values_for_allowed_attributes)).each do |key, value|
      expect(instance_attributes[key]).to eq(value)
    end
  end

  it "updates paused resource with allowed attributes" do
    stub_const("ENV", "BYPASS_RBAC" => "true")
    new_attributes = instance_attributes_for(model_klass, new_values_for_allowed_attributes)

    patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

    expect(response).to have_attributes(:status => 204)

    instance.reload

    instance_attributes = instance.attributes
    instance_attributes_for(model_klass, new_values_for_allowed_attributes).each do |key, value|
      expect(instance_attributes[key]).to eq(value)
    end
  end
end
