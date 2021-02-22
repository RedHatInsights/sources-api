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

    context "#availability_status check after update" do
      it "calls for check with `nil` status" do
        expect(Sources::Api::Messaging.client).to receive(:publish_topic).with(
          {
            :service => "platform.topological-inventory.operations-#{record.source_type.name}",
            :event   => "Source.availability_check",
            :payload => {
              :params => {
                :source_id       => record.id.to_s,
                :source_uid      => record.uid.to_s,
                :source_ref      => record.source_ref.to_s,
                :external_tenant => record.tenant.external_tenant
              }
            }
          }
        )

        record.update!(update)
      end

      it "does not call for check with `available` status" do
        expect(record).not_to receive(:availability_check)
        expect(record).to receive(:update_status)

        record.update!(no_update)
      end

      it "does not call for check with `unavailable` status" do
        record.update!(:availability_status => unavailable_status)
        expect(record).not_to receive(:availability_check)
        expect(record).to receive(:update_status)

        record.update!(no_update)
      end
    end
  end
end
