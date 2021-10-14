describe("RBAC requests") do
  include ::Spec::Support::TenantIdentity
  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => user_identity} }
  let(:source_type) { create(:source_type, :name => "SourceType", :vendor => "Some Vendor", :product_name => "Product Name") }
  let(:attributes) { {"name" => "my source", "source_type_id" => source_type.id.to_s} }

  before do
    allow(Sources::Api::Events).to receive(:raise_event).and_return(true)
  end

  context "when making requests that do not require rbac" do
    it "does not query rbac" do
      expect(Sources::RBAC::Access).not_to receive(:enabled?)

      get("/api/v3.0/sources", :headers => headers)
      expect(response.status).to eq 200
    end
  end

  context "when making a rbac enforced request" do
    let(:rbac_access) { instance_double(Insights::API::Common::RBAC::Access) }

    before do
      allow(Sources::RBAC::Access).to receive(:enabled?).and_return(true)
    end

    context "when no psk is present" do
      context "when the user has write access" do
        before do
          allow(Sources::RBAC::Access).to receive(:write_access?).and_return(true)
        end

        it "allows the operation" do
          expect(Sources::RBAC::Access).to receive(:enabled?).once
          post("/api/v3.0/sources", :params => attributes.to_json, :headers => headers)

          expect(response).to have_attributes(
            :status      => 201,
            :location    => "http://www.example.com/api/v3.0/sources/#{response.parsed_body["id"]}",
            :parsed_body => a_hash_including(attributes)
          )
        end
      end

      context "when the user does not have write access" do
        before do
          allow(Sources::RBAC::Access).to receive(:write_access?).and_return(false)
        end

        it "denies the operation" do
          expect(Sources::RBAC::Access).to receive(:enabled?).once

          post("/api/v3.0/sources", :params => attributes.to_json, :headers => headers)
          expect(response).to have_attributes(
            :status      => 403,
            :location    => nil,
            :parsed_body => {"errors"=>[{"status" => "403", "detail" => "You are not authorized to perform the create action for this source"}]}
          )
        end
      end
    end

    context "with a psk and no x-rh-id" do
      let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-sources-psk" => "1234", "x-rh-sources-account-number" => external_tenant} }

      before do
        allow(DefaultPolicy).to receive(:pre_shared_keys).and_return(%w(1234))
      end

      it "allows the request to go through" do
        expect(Sources::RBAC::Access).to receive(:enabled?).once
        post("/api/v3.0/sources", :params => attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v3.0/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(attributes)
        )
      end
    end
  end
end
