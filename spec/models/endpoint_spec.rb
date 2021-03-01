require "models/shared/availability_status.rb"

describe Endpoint do
  include ::Spec::Support::TenantIdentity

  include_context "availability_status_context"
  it_behaves_like "availability_status_examples" do
    let!(:source)    { create(:source, :availability_status => available_status, :last_checked_at => timestamp) }
    let!(:record)    { create(:endpoint, :source => source, :availability_status => available_status) }
    let!(:update)    { {:path => 'new_path'} }
    let!(:no_update) { {:path => record.path} }

    context "#with changes" do
      it "resets availability status for related source" do
        record.update!(update)

        expect(record.source.availability_status).to eq(nil)
        expect(record.source.last_checked_at).to eq(nil)
      end
    end

    context "#without changes" do
      it "does not reset availability status for related source" do
        record.update!(no_update)

        expect(record.source.availability_status).to eq(available_status)
        expect(record.source.last_checked_at).to eq(timestamp)
      end
    end
  end

  describe "#base_url_path" do
    let(:endpoint) { described_class.new(:host => "www.example.com", :port => 1234, :scheme => "https") }

    it "combines the various attributes to create a full url" do
      expect(endpoint.base_url_path).to eq("https://www.example.com:1234")
    end
  end

  describe "#default" do
    let(:source) { create(:source, :tenant => tenant) }

    it "allows only one default endpoint" do
      described_class.create!(:role => "first", :default => true, :tenant => tenant, :source => source)
      expect { described_class.create!(:role => "second", :default => true, :tenant => tenant, :source => source) }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "sets the first endpoint created as default" do
      endpoint = described_class.create!(:role => "first", :tenant => tenant, :source => source)
      expect(endpoint.default).to be_truthy

      endpoint2 = described_class.create!(:role => "second", :tenant => tenant, :source => source)
      expect(endpoint2.default).to be_falsey
    end

    it "sets default on an endpoint that gets re-added" do
      endpoint = described_class.create!(:role => "first", :tenant => tenant, :source => source)
      expect(endpoint.default).to be_truthy

      endpoint.delete

      endpoint2 = described_class.create!(:role => "second", :tenant => tenant, :source => source)
      expect(endpoint2.default).to be_truthy
    end
  end
end
