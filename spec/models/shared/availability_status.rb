RSpec.shared_context "availability_status_context" do
  let(:timestamp)                 { Time.current }
  let(:new_timestamp)             { Time.current + 1.hour }
  let(:available_status)          { "available" }
  let(:unavailable_status)        { "unavailable" }
  let(:new_name)                  { "new_name" }
  let(:availability_status_error) { "availability_status_error" }

  let(:ignored_attributes) do
    new_attributes = {
      :availability_status => unavailable_status,
      :last_checked_at     => new_timestamp,
      :last_available_at   => new_timestamp
    }

    if record.respond_to?(:updated_at)
      new_attributes[:updated_at] = new_timestamp
    end

    if record.respond_to?(:availability_status_error)
      new_attributes[:availability_status_error] = availability_status_error
    end

    if record.respond_to?(:name)
      new_attributes[:name] = new_name
    end

    new_attributes
  end
end

RSpec.shared_examples "availability_status_examples" do
  before do
    allow(source).to receive(:availability_check) if source.present?
    allow(record).to receive(:availability_check) if record.respond_to?(:availability_check)
  end

  # record, update and no_update variables come from caller spec
  describe "#before_update" do
    before do
      record.availability_status = available_status
      record.last_checked_at = timestamp
    end

    context "with changes" do
      it "sets availability_status to nil" do
        record.update!(update)

        expect(record.availability_status).to eq(nil)
        expect(record.last_checked_at).to eq(nil)

        if record.respond_to?(:availability_status_error)
          expect(record.availability_status_error).to eq(nil)
        end
      end

      it "ignores attribute changes from IGNORE_LIST" do
        record.update!(ignored_attributes)

        expect(record.availability_status).to eq(unavailable_status)
        expect(record.last_checked_at).to eq(ignored_attributes[:last_checked_at])
        expect(record.last_available_at).to eq(ignored_attributes[:last_available_at])

        if record.respond_to?(:updated_at)
          expect(record.updated_at).to eq(new_timestamp)
        end

        if record.respond_to?(:availability_status_error)
          expect(record.availability_status_error).to eq(availability_status_error)
        end

        if record.respond_to?(:name)
          expect(record.name).to eq(new_name)
        end
      end
    end

    context "without changes" do
      it "keeps availability_status unchanged" do
        record.update!(no_update)

        expect(record.availability_status).to eq(available_status)
        expect(record.last_checked_at).to eq(timestamp)
      end
    end
  end
end
