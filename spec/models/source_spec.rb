require 'models/shared/availability_status'

describe Source do
  include_context "availability_status_context"
  it_behaves_like "availability_status_examples" do
    let!(:update)    { {:version => '1.1'} }
    let!(:no_update) { {:version => '1'} }
    let!(:record) do
      res = create(:source, :version => '1')
      res.update!(:availability_status => available_status)
      res
    end
  end

  context "when destroying a superkey application" do
    let!(:source) { create(:source, :app_creation_workflow => Source::SUPERKEY_WORKFLOW) }
    let!(:app) { create(:application, :source => source) }

    it "doesn't allow destroying the source when there are applications attached" do
      Insights::API::Common::Request.with_request(default_request) do
        expect { source.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed, /Applications must be removed/)
      end
    end
  end
end
