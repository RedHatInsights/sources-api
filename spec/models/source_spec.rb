require "models/shared/availability_status.rb"

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
end
