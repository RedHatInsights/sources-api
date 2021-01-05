require "models/shared/availability_status.rb"

describe Source do
  it_behaves_like "availability_status" do
    let!(:record)    { create(:source, :version => '1') }
    let!(:update)    { {:version => '1.1'} }
    let!(:no_update) { {:version => '1'} }
  end
end
