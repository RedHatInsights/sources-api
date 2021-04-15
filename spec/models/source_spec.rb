require "models/shared/availability_status.rb"

describe Source do
  include_context "availability_status_context"
  it_behaves_like "availability_status_examples" do
    let!(:source) { nil } # for compatibility with shared example
    let!(:update)    { {:version => '1.1'} }
    let!(:no_update) { {:version => '1'} }
    let!(:record) { create(:source, :version => '1', :availability_status => available_status) }
  end
end
