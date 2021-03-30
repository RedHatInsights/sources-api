require "models/shared/availability_status"

describe Authentication do
  before { SourceType.seed }

  let(:amazon) { SourceType.find_by(:name => "amazon") }
  let!(:source) { create(:source, :source_type => amazon, :app_creation_workflow => Source::SUPERKEY_WORKFLOW) }

  context "when creating superkey authentication" do
    let!(:authentication) { create(:authentication, :resource => source, :authtype => amazon.superkey_authtype) }

    it "only allows one superkey auth per source" do
      expect do
        Authentication.create!(
          :resource => source,
          :authtype => amazon.superkey_authtype,
          :tenant   => source.tenant
        )
      end.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it "allows updating the superkey record" do
      expect { authentication.update!(:username => "another thing") }.not_to raise_error
    end
  end

  context "available_status" do
    include_context "availability_status_context"

    let(:endpoint) { create(:endpoint, :source => source) }
    let(:record) { create(:authentication, :source => source, :resource => endpoint) }

    before do
      status = {:availability_status => available_status, :last_checked_at => timestamp}
      record.update!(status)
      source.update!(status)
      endpoint.update!(status)
    end

    it_behaves_like "availability_status_examples" do
      let!(:update)    { {:username => 'new_username', :password => 'new_password'} }
      let!(:no_update) { {:username => record.username} }

      context "#with changes" do
        it "resets availability status for related source" do
          record.update!(update)

          expect(record.source.availability_status).to eq(nil)
          expect(record.source.last_checked_at).to eq(nil)
        end

        it "resets availability status for related resource" do
          record.update!(update)

          expect(record.resource.availability_status).to eq(nil)
          expect(record.resource.last_checked_at).to eq(nil)
        end
      end

      context "#without changes" do
        it "does not reset availability status for related source" do
          record.update!(no_update)

          expect(record.source.availability_status).to eq(available_status)
          expect(record.source.last_checked_at).to eq(timestamp)
        end

        it "does not reset availability status for related resource" do
          record.update!(no_update)

          expect(record.resource.availability_status).to eq(available_status)
          expect(record.source.last_checked_at).to eq(timestamp)
        end
      end
    end

    describe "#destroy!" do
      it "resets related source status" do
        allow(record).to receive(:raise_event)

        record.destroy!

        expect(source.availability_status).to be_nil
      end

      it "resets related resource status" do
        allow(record).to receive(:raise_event)

        record.destroy!

        expect(record.resource.availability_status).to be_nil
      end
    end
  end

  context "when trying to add an authentiction to a non-superkey source" do
    let(:source) { create(:source) }

    it "does not allow the creation" do
      expect { Authentication.create!(:resource => source) }.to raise_error(ActiveRecord::RecordInvalid, /Only superkey sources/)
    end
  end
end
