require "models/shared/availability_status"

describe Authentication do
  include_context "availability_status_context"
  it_behaves_like "availability_status_examples" do
    let(:authtype1) { 'token' }
    let(:authtype2) { 'username_password' }
    let(:source) { create(:source, :availability_status => available_status, :last_checked_at => timestamp) }
    let(:record) { create(:authentication, :source => source, :resource => source, :availability_status => available_status, :authtype => authtype1) }
    let(:no_update) { {:authtype => authtype1} }
    let(:update) { {:authtype => authtype2} }

    context "#with changes" do
      context "with endpoint resource" do
        let(:endpoint) { create(:endpoint, :source => source, :last_checked_at => timestamp) }
        let(:record) { create(:authentication, :source => source, :resource => endpoint, :availability_status => available_status, :authtype => authtype1) }

        it "resets availability status for related endpoint and source" do
          expect(record.source).to receive(:availability_check)

          record.update!(update)

          expect(record.resource.availability_status).to eq(nil)
          expect(record.resource.last_checked_at).to eq(nil)
          expect(record.resource.source.availability_status).to eq(nil)
          expect(record.resource.source.last_checked_at).to eq(nil)
        end
      end

      context "with application resource" do
        let(:application) { create(:application, :source => source, :availability_status => available_status, :last_checked_at => timestamp) }
        let(:record) { create(:authentication, :source => source, :resource => application, :availability_status => available_status, :authtype => authtype1) }

        before { allow(application).to receive(:availability_check) }

        %w[without_m_n_relation with_m_n_relation].each do |option|
          context option do
            if option == 'with_m_n_relation'
              let(:application_authentication) { create(:application_authentication, :application => application, :authentication => record) }
            end

            it "resets availability status for related application and source" do
              expect(record.source).not_to receive(:availability_check)
              expect(record.resource).to receive(:availability_check)

              record.update!(update)

              expect(record.resource.availability_status).to eq(nil)
              expect(record.resource.last_checked_at).to eq(nil)
              expect(record.resource.source.availability_status).to eq(nil)
              expect(record.resource.source.last_checked_at).to eq(nil)
            end
          end
        end
      end
    end

    context "#without changes" do
      context "with endpoint resource" do
        let(:endpoint) { create(:endpoint, :source => source, :availability_status => available_status, :last_checked_at => timestamp) }
        let(:record) { create(:authentication, :source => source, :resource => endpoint, :availability_status => available_status, :authtype => authtype1) }

        it "resets availability status for related endpoint and source" do
          expect(record.source).not_to receive(:availability_check)

          record.update!(no_update)

          expect(record.resource.availability_status).to eq(available_status)
          expect(record.resource.last_checked_at).to eq(timestamp)
          expect(record.resource.source.availability_status).to eq(available_status)
          expect(record.resource.source.last_checked_at).to eq(timestamp)
        end
      end

      context "with application resource" do
        let(:application) { create(:application, :source => source, :availability_status => available_status, :last_checked_at => timestamp) }
        let(:record) { create(:authentication, :source => source, :resource => application, :availability_status => available_status, :authtype => authtype1) }

        before { allow(application).to receive(:availability_check) }

        %w[without_m_n_relation with_m_n_relation].each do |option|
          context option do
            if option == 'with_m_n_relation'
              let(:application_authentication) { create(:application_authentication, :application => application, :authentication => record) }
            end

            it "resets availability status for related application and source" do
              expect(record.source).not_to receive(:availability_check)

              record.update!(no_update)

              expect(record.resource.availability_status).to eq(available_status)
              expect(record.resource.last_checked_at).to eq(timestamp)
              expect(record.resource.source.availability_status).to eq(available_status)
              expect(record.resource.source.last_checked_at).to eq(timestamp)
            end
          end
        end
      end
    end
  end

  context "seeded" do
    before { SourceType.seed }

    context "when creating superkey authentication" do
      let(:amazon) { SourceType.find_by(:name => "amazon") }
      let!(:source) { create(:source, :source_type => amazon, :app_creation_workflow => Source::SUPERKEY_WORKFLOW) }
      let!(:authentication) { create(:authentication, :resource => source, :authtype => amazon.superkey_authtype) }

      before do
        allow(source).to receive(:availability_check)
      end

      it "only allows one superkey auth per source" do
        expect do
          Authentication.create!(
            :resource => source,
            :authtype => amazon.superkey_authtype,
            :tenant   => source.tenant
          )
        end.to raise_error(ActiveRecord::ActiveRecordError)
      end

      it "allows updating the superkey record" do
        expect { authentication.update!(:username => "another thing") }.not_to raise_error
      end
    end
  end
end
