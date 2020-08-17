RSpec.describe("Application") do
  describe "create!" do
    subject do
      create(:application, :source => source)
    end

    context "when the application supports the given source type" do
      let(:source) { create(:source) }

      it "should return an instance of Application" do
        expect(subject).to be_an_instance_of(Application)
      end
    end

    context "when the application does not support the given source type" do
      let(:source) { create(:source, :compatible => false) }

      it "should raise RecordInvalid" do
        expect do
          subject
        end.to raise_error(ActiveRecord::RecordInvalid, /^.* is not compatible with this application type/)
      end
    end
  end
end
