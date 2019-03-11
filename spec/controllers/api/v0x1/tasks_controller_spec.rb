RSpec.describe Api::V0x1::TasksController, :type => :request do
  it("Uses IndexMixin")   { expect(described_class.instance_method(:index).owner).to eq(Api::V0x1::Mixins::IndexMixin) }
  it("Uses ShowMixin")    { expect(described_class.instance_method(:show).owner).to eq(Api::V0::Mixins::ShowMixin) }
  it("Uses UpdateMixin")  { expect(described_class.instance_method(:update).owner).to eq(Api::V0::Mixins::UpdateMixin) }

  let(:tenant) { Tenant.create! }

  it "patch /tasks/:id updates a Task" do
    task = Task.create!(:state => "running", :status => "ok", :context => "context1", :tenant => tenant)

    patch(api_v0x1_task_url(task.id), :params => {:state => "completed", :status => "ok", :context => "context2"}.to_json)

    expect(task.reload.state).to eq("completed")
    expect(task.reload.status).to eq("ok")
    expect(task.context).to eq("context2")

    expect(response.status).to eq(204)
    expect(response.parsed_body).to be_empty
  end
end
