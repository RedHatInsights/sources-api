RSpec.describe("Application") do
  include ::Spec::Support::TenantIdentity

  let(:compatible_source)         { Source.create!(:source_type => compatible_source_type, :tenant => tenant, :uid => SecureRandom.uuid, :name => "my-source") }
  let(:compatible_source_type)    { SourceType.create!(:name => "my-source-type", :product_name => "My Source Type", :vendor => "ACME") }

  let(:incompatible_source)       { Source.create!(:source_type => incompatible_source_type, :tenant => tenant, :uid => SecureRandom.uuid, :name => "not-my-source") }
  let(:incompatible_source_type)  { SourceType.create!(:name => "not-my-source-type", :product_name => "Not My Source Type", :vendor => "ACME") }

  let(:application_type)  { ApplicationType.create!("name" => "my-application", :supported_source_types => ["my-source-type"]) }

  let(:attributes) do
    {
      :application_type_id => application_type.id,
      :tenant              => tenant
    }
  end

  describe "Application" do
    context "create!" do
      it "Should return an instance of Application on success" do
        expect(
          Application.create!(attributes.merge(:source_id => compatible_source.id))
        ).to be_an_instance_of(Application)
      end

      it "Should raise RecordInvalid when given an incompatible source" do
        expect do
          Application.create!(attributes.merge(:source_id => incompatible_source.id))
        end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Source is not compatible with this application type")
      end
    end
  end
end
