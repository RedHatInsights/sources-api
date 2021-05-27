require "models/shared/availability_status.rb"

RSpec.describe("Application") do
  include_context "availability_status_context"
  it_behaves_like "availability_status_examples" do
    let(:source)    { create(:source, :availability_status => available_status, :last_checked_at => timestamp) }
    let(:update)    { {:application_type => app_type2} }
    let(:no_update) { {:application_type => app_type} }
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

    let(:source_unavailable) { create(:source, :availability_status => unavailable_status, :last_checked_at => timestamp) }
    let(:application2) { create(:application, :source => source_unavailable, :application_type => app_type, :availability_status => unavailable_status) }

    context "#with changes" do
      it "resets availability status for related source" do
        expect(record.source).not_to receive(:availability_check)
        expect(record).to receive(:availability_check)

        record.update!(update)

        expect(record.source.availability_status).to eq(nil)
        expect(record.source.last_checked_at).to eq(nil)
      end

      it "sets availability status for related source" do
        expect(application2).not_to receive(:availability_check)
        expect(application2.source).not_to receive(:availability_check)

        application2.update!(:availability_status       => available_status,
                             :availability_status_error => availability_status_error,
                             :last_checked_at           => new_timestamp)

        expect(application2.source.availability_status).to eq(available_status)
        expect(application2.source.last_checked_at).to eq(new_timestamp)
      end
    end

    context "#without changes" do
      it "does not reset availability status for related source" do
        expect(record).not_to receive(:availability_check)
        expect(record.source).not_to receive(:availability_check)

        record.update!(no_update)

        expect(record.source.availability_status).to eq(available_status)
        expect(record.source.last_checked_at).to eq(timestamp)
      end

      it "does not set availability status for related source" do
        expect(application2).not_to receive(:availability_check)
        expect(application2.source).not_to receive(:availability_check)

        application2.update!(:superkey_data => {:they_are => 'ignored'})

        expect(application2.source.availability_status).to eq(unavailable_status)
        expect(application2.source.last_checked_at).to eq(timestamp)
      end
    end
  end

  describe "availability_check" do
    let(:available_status) { "available" }
    let(:source) { create(:source, :availability_status => available_status, :last_checked_at => 1.hour.ago) }

    let(:app_type) { create(:application_type, :name => 'old_app_type') }
    let(:app_type2) { create(:application_type, :name => 'new_app_type') }
    let(:application) { create(:application, :source => source, :application_type => app_type, :availability_status => available_status) }
    let(:application2) { create(:application, :source => source, :application_type => app_type2, :availability_status => available_status) }

    context "when reset_availability called" do
      %w[with without].each do |endpoint_presence|
        context "for source #{endpoint_presence} endpoint" do
          if endpoint_presence == 'with'
            let(:endpoint) { create(:endpoint, :source => source) }
          end

          it "calls app's availability_check only" do
            expect(application.source).not_to receive(:availability_check)
            expect(application).to receive(:availability_check).once
            expect(application2).not_to receive(:availability_check)

            application.reset_availability
          end
        end
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

  describe "superkey" do
    let!(:source) { create(:source, :app_creation_workflow => "account_authorization") }
    let!(:apptype) { create(:application_type, :supported_source_types => [source.source_type.name]) }
    let!(:sk) { instance_double(Sources::SuperKey) }

    let(:client) { instance_double("ManageIQ::Messaging::Client") }
    let(:redis) { instance_double("Redis") }

    before do
      allow(client).to receive(:publish_topic)
      allow(Sources::Api::Messaging).to receive(:client).and_return(client)

      allow(Sources::SuperKey).to receive(:new).and_return(sk)

      allow(Redis).to receive(:current).and_return(redis)
      allow(redis).to receive(:get).and_return(nil)
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
          expect(SuperkeyDeleteJob).to receive(:perform_later).with(application).once

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

  describe "pausing" do
    let!(:source) { create(:source) }
    let!(:app1) { Application.create!(:source => source, :tenant => source.tenant, :application_type => create(:application_type)) }
    let!(:app2) { Application.create!(:source => source, :tenant => source.tenant, :application_type => app1.application_type) }
    let!(:auth) { Authentication.create!(:resource => app1, :tenant => source.tenant) }

    before do
      # TODO: i have no idea why this is necessary. it doesn't make sense
      app1.authentications << auth
    end

    it "discards dependent authentications" do
      app1.discard

      expect(auth.reload.discarded?).to be_truthy
    end

    it "discards the source when all applications are discarded" do
      app1.discard
      app2.discard

      expect(app1.reload.source.discarded?).to be_truthy
    end
  end
end
