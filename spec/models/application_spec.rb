require "models/shared/availability_status.rb"

RSpec.describe("Application") do
  let(:available_status) { 'available' }
  let(:source)    { create(:source, :availability_status => available_status, :last_checked_at => timestamp) }
  let(:app_type)  { create(:application_type, :name => 'old_app_type') }
  let(:app_type2) { create(:application_type, :name => 'new_app_type') }
  let(:record) do
    create(
      :application,
      :source              => source,
      :application_type    => app_type,
      :availability_status => available_status
    )
  end

  include_context "availability_status_context"
  it_behaves_like "availability_status_examples" do
    let(:update)    { {:application_type => app_type2} }
    let(:no_update) { {:application_type => app_type} }

    context "#with changes" do
      it "resets availability status for related source" do
        record.update!(update)

        expect(record.source.availability_status).to eq(nil)
        expect(record.source.last_checked_at).to eq(nil)
      end
    end

    context "#without changes" do
      it "does not reset availability status for related source" do
        record.update!(no_update)

        expect(record.source.availability_status).to eq(available_status)
        expect(record.source.last_checked_at).to eq(timestamp)
      end
    end
  end

  describe "create!" do
    subject do
      create(:application, :source => source)
    end

    context "when the application supports the given source type" do
      let(:source) { create(:source) }

      it "should return an instance of Application" do
        expect(subject).to be_an_instance_of(Application)
      end
    end

    context "when the application does not support the given source type" do
      let(:source) { create(:source, :compatible => false) }

      it "should raise RecordInvalid" do
        expect do
          subject
        end.to raise_error(ActiveRecord::RecordInvalid, /^.* is not compatible with this application type/)
      end
    end
  end

  describe "#destroy!" do
    it "resets related source status" do
      allow(record).to receive(:raise_event)

      record.destroy!

      expect(source.availability_status).to be_nil
    end

    it "does not reset related source status" do
      endpoint = create(:endpoint, :source => source, :availability_status => available_status)
      allow(record).to receive(:raise_event)

      record.destroy!

      expect(source.availability_status).to eq(available_status)
      expect(endpoint.availability_status).to eq(available_status)
    end
  end
  
  describe "superkey" do
    let!(:source) { create(:source, :app_creation_workflow => "account_authorization") }
    let!(:apptype) { create(:application_type, :supported_source_types => [source.source_type.name]) }
    let!(:sk) { instance_double(Sources::SuperKey) }

    let(:client) { instance_double("ManageIQ::Messaging::Client") }

    before do
      allow(client).to receive(:publish_topic)
      allow(Sources::Api::Messaging).to receive(:client).and_return(client)

      allow(Sources::SuperKey).to receive(:new).and_return(sk)
    end

    context "on create" do
      context "when there is a superkey authentication" do
        it "runs the superkey workflow" do
          _auth = Authentication.create!(:resource => source, :tenant => source.tenant, :username => "foo", :password => "bar")
          expect(sk).to receive(:create).once

          Application.create!(:source => source, :tenant => Tenant.first, :application_type_id => apptype.id)
        end
      end

      context "when there is not a superkey authentication" do
        it "does not run the superkey workflow" do
          expect(sk).not_to receive(:create)

          Application.create!(:source => source, :tenant => Tenant.first, :application_type_id => apptype.id)
        end
      end
    end

    context "on destroy" do
      let!(:application) { create(:application, :application_type => apptype, :source => source) }

      context "when there is a superkey authentication" do
        it "runs the superkey workflow" do
          _auth = Authentication.create!(:resource => source, :tenant => source.tenant, :username => "foo", :password => "bar")
          source.reload
          expect(sk).to receive(:teardown).once

          application.destroy!
        end
      end

      context "when there is not a superkey authentication" do
        it "does not run the superkey workflow" do
          expect(sk).not_to receive(:teardown)

          application.destroy!
        end
      end
    end
  end
end