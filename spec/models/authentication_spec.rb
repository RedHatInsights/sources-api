require "models/shared/availability_status.rb"

describe Authentication do
  it_behaves_like "availability_status" do
    let!(:record)    { create(:authentication, :resource => create(:endpoint)) }
    let!(:update)    { {:username => 'new_username', :password => 'new_password'} }
    let!(:no_update) { {:username => record.username} }
  end
end
