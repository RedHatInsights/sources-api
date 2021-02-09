require "models/shared/availability_status.rb"

describe Authentication do
  include_context "availability_status_context"
  it_behaves_like "availability_status_examples" do
    let!(:record)    { create(:authentication, :resource => create(:endpoint)) }
    let!(:update)    { {:username => 'new_username', :password => 'new_password'} }
    let!(:no_update) { {:username => record.username} }
  end
end
