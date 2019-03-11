RSpec.describe("v0.1 - SourceTypes") do
  let(:attributes)      { {"name" => "test_name", "product_name" => "Test Product", "vendor" => "TestVendor"} }
  let(:collection_path) { "/api/v0.1/source_types" }

  describe("/api/v0.1/source_types") do
    context "get" do
      it "success: empty collection" do
        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        SourceType.create!(attributes)

        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes)])
        )
      end
    end

    context "post" do
      it "success: with valid body" do
        post(collection_path, :params => attributes.to_json)

        expect(response).to have_attributes(
          :status => 201,
          :location => "http://www.example.com/api/v0.1/source_types/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(attributes)
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

  describe("/api/v0.1/source_types/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = SourceType.create!(attributes)

        get(instance_path(instance.id))

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s))
        )
      end

      it "failure: with an invalid id" do
        instance = SourceType.create!(attributes)

        get(instance_path(instance.id * 1000))

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => ""
        )
      end
    end
  end

  describe("/api/v0.1/source_types/:id/sources") do
    def subcollection_path(id, subcollection)
      File.join(collection_path, id.to_s, subcollection)
    end

    context "get" do
      it "success: with a valid id" do
        instance = SourceType.create!(attributes)

        get(subcollection_path(instance.id, "sources"))

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "failure: with an invalid id" do
        instance = SourceType.create!(attributes)
        missing_id = (instance.id * 1000)
        expect(Source.exists?(missing_id)).to eq(false)

        get(subcollection_path(missing_id, "sources"))

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Couldn't find SourceType with 'id'=#{missing_id}", "status"=>404}]}
        )
      end
    end
  end
end
