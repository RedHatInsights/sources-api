require "models/shared/availability_status"

describe Authentication do
  context "when creating superkey authentication" do
    before { SourceType.seed }

    let(:amazon) { SourceType.find_by(:name => "amazon") }
    let!(:source) { create(:source, :source_type => amazon, :app_creation_workflow => Source::SUPERKEY_WORKFLOW) }
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
end
