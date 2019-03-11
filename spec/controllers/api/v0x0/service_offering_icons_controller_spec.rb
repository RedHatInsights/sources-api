RSpec.describe Api::V0x0::ServiceOfferingIconsController, :type => :request do
  it("Uses IndexMixin") { expect(described_class.instance_method(:index).owner).to eq(Api::V0::Mixins::IndexMixin) }
  it("Uses ShowMixin")  { expect(described_class.instance_method(:show).owner).to eq(Api::V0::Mixins::ShowMixin) }
end
