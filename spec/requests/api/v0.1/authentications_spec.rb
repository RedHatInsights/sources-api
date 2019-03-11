RSpec.describe("v0.1 - Authentications") do
  let(:attributes)      { {"username" => "test_name", "password" => "Test Password", "tenant_id" => tenant.id.to_s, "resource_type" => "Tenant", "resource_id" => tenant.id.to_s} }
  let(:collection_path) { "/api/v0.1/authentications" }
  let(:tenant)          { Tenant.create! }

  describe("/api/v0.1/authentications") do
    context "get" do
      it "success: empty collection" do
        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        Authentication.create!(attributes)

        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes.except("password"))])
        )
      end
    end

    context "post" do
      it "success: with valid body" do
        post(collection_path, :params => attributes.to_json)

        expect(response).to have_attributes(
          :status => 201,
          :location => "http://www.example.com/api/v0.1/authentications/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(attributes.except("password"))
        )
      end

      it "failure: with no body" do
        post(collection_path)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => TopologicalInventory::Api::ErrorDocument.new.add(400, "Failed to parse POST body, expected JSON")
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => attributes.merge("aaa" => "bbb").to_json)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => TopologicalInventory::Api::ErrorDocument.new.add(400, "found unpermitted parameter: :aaa")
        )
      end
    end
  end

  describe("/api/v0.1/authentications/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = Authentication.create!(attributes)

        get(instance_path(instance.id))

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => attributes.except("password").merge("id" => instance.id.to_s)
        )
      end

      it "failure: with an invalid id" do
        instance = Authentication.create!(attributes)

        get(instance_path(instance.id * 1000))

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => ""
        )
      end
    end
  end
end
