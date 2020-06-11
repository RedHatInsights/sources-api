RSpec.describe("Application") do
  include ::Spec::Support::TenantIdentity

  describe "create!" do
    let(:compatible_source)       { Source.create!(:source_type => compatible_source_type, :tenant => tenant, :uid => SecureRandom.uuid, :name => "my-source") }
    let(:compatible_source_type)  { SourceType.create!(:name => "my-source-type", :product_name => "My Source Type", :vendor => "ACME") }

    let(:incompatible_source)       { Source.create!(:source_type => incompatible_source_type, :tenant => tenant, :uid => SecureRandom.uuid, :name => "not-my-source") }
    let(:incompatible_source_type)  { SourceType.create!(:name => "not-my-source-type", :product_name => "Not My Source Type", :vendor => "ACME") }

    let(:application_type)  { ApplicationType.create!("name" => "my-application", :supported_source_types => ["my-source-type"]) }

    subject do
      Application.create!({
        :application_type_id => application_type.id,
        :source_id           => source.id,
        :tenant              => tenant
      })
    end

    context "when the application supports the given source type" do
      let(:source) { compatible_source }

      it "should return an instance of Application" do
        expect(subject).to be_an_instance_of(Application)
      end
    end

    context "when the application does not support the given source type" do
      let(:source) { incompatible_source }

      it "should raise RecordInvalid" do
        expect do
          subject
        end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Source is not compatible with this application type")
      end
    end
  end
end
