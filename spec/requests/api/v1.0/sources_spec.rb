RSpec.describe("v1.0 - Sources") do
  include ::Spec::Support::TenantIdentity

  let(:headers)         { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:attributes)      { {"name" => "my source", "source_type_id" => source_type.id.to_s} }
  let(:collection_path) { "/api/v1.0/sources" }
  let(:source_type)     { SourceType.create!(:name => "SourceType", :vendor => "Some Vendor", :product_name => "Product Name") }
  let(:client)          { instance_double("ManageIQ::Messaging::Client") }
  before do
    allow(client).to receive(:publish_topic)
    allow(Sources::Api::Events).to receive(:messaging_client).and_return(client)
  end

  describe("/api/v1.0/sources") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        Source.create!(attributes.merge("tenant" => tenant))

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes)])
        )
      end
    end

    context "post" do
      it "success: with valid body" do
        post(collection_path, :params => attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 201,
          :location => "http://www.example.com/api/v1.0/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(attributes)
        )
      end

      it "failure: with no body" do
        post(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "Failed to parse POST body, expected JSON").to_h
        )
      end

      it "failure: with a missing name attribute" do
        post(collection_path, :params => attributes.except("name").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "Invalid parameter - Validation failed: Name can't be blank").to_h
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => attributes.merge("aaa" => "bbb").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :location => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "properties aaa are not defined in #/components/schemas/Source").to_h
        )
      end

      it "failure: with a blank name attribute" do
        post(collection_path, :params => attributes.merge("name" => "").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "Invalid parameter - Validation failed: Name can't be blank").to_h
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => attributes.merge("source_type_id" => "xxx").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "xxx isn't match ^\\d+$ in #/components/schemas/ID").to_h
        )
      end

      it "failure: with a duplicate name in the same tenant" do
        2.times do
          post(collection_path, :params => attributes.to_json, :headers => headers)
        end

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(
            400, "Invalid parameter - Validation failed: Name has already been taken").to_h
        )
      end

      it "success: with a duplicate name in a different tenant" do
        post(collection_path, :params => attributes.to_json, :headers => headers)

        second_tenant = rand(1000).to_s
        second_identity = {"x-rh-identity" => Base64.encode64({"identity" => {"account_number" => second_tenant}}.to_json)}
        post(collection_path, :params => attributes.to_json, :headers => headers.merge(second_identity))

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v1.0/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(attributes)
        )
      end

      it "failure: with a not unique UID" do
        post(collection_path, :params => attributes.merge("name" => "aaa", "uid" => "123").to_json, :headers => headers)
        post(collection_path, :params => attributes.merge("name" => "abc", "uid" => "123").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "Record not unique").to_h
        )
      end
    end
  end

  describe("/api/v1.0/sources/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = Source.create!(attributes.merge("tenant" => tenant))

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s))
        )
      end

      it "failure: with an invalid id" do
        instance = Source.create!(attributes.merge("tenant" => tenant))

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>404}]}
        )
      end
    end

    context "patch" do
      it "success: with a valid id" do
        instance = Source.create!(attributes.merge("tenant" => tenant))
        new_attributes = {"name" => "new name"}

        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 204,
          :parsed_body => ""
        )

        expect(instance.reload).to have_attributes(new_attributes)
      end

      it "failure: with an invalid id" do
        instance = Source.create!(attributes.merge("tenant" => tenant))
        new_attributes = {"name" => "new name"}

        patch(instance_path(instance.id * 1000), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>404}]}
        )
      end

      it "failure: with extra parameters" do
        instance = Source.create!(attributes.merge("tenant" => tenant))
        new_attributes = {"aaaaa" => "bbbbb"}

        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :parsed_body => {"errors" => [{"detail"=>"properties aaaaa are not defined in #/components/schemas/Source", "status" => 400}]}
        )
      end

      it "failure: with read-only parameters" do
        instance = Source.create!(attributes.merge("tenant" => tenant))
        new_attributes = {"uid" => "xxxxx"}

        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status => 400,
          :parsed_body => {"errors" => [{"detail"=>"found unpermitted parameter: :uid", "status" => 400}]}
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => attributes.merge("source_type_id" => 4).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "4 class is Integer but it's not valid string in #/components/schemas/ID").to_h
        )
      end

      it "failure: with an invalid availability_status value" do
        post(collection_path, :params => attributes.merge("availability_status" => "bogus").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => ManageIQ::API::Common::ErrorDocument.new.add(400, "Invalid parameter - Validation failed: Availability status is not included in the list").to_h
        )
      end

      it "success: with an available availability_status" do
        included_attributes = { "name" => "availability_source", "availability_status" => "available" }

        post(collection_path, :params => attributes.merge(included_attributes).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v1.0/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(included_attributes)
        )
      end

      it "success: with a partially_available availability_status" do
        included_attributes = { "name" => "availability_source", "availability_status" => "partially_available" }

        post(collection_path, :params => attributes.merge(included_attributes).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v1.0/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(included_attributes)
        )
      end

      it "success: with an unavailable availability_status" do
        included_attributes = { "name" => "availability_source", "availability_status" => "unavailable" }

        post(collection_path, :params => attributes.merge(included_attributes).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v1.0/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(included_attributes)
        )
      end
    end
  end

  describe("subcollections") do
    existing_subcollections = [
      "endpoints",
    ]

    existing_subcollections.each do |subcollection|
      describe("/api/v1.0/sources/:id/#{subcollection}") do
        let(:subcollection) { subcollection }

        def subcollection_path(id)
          File.join(collection_path, id.to_s, subcollection)
        end

        context "get" do
          it "success: with a valid id" do
            instance = Source.create!(attributes.merge("tenant" => tenant))

            get(subcollection_path(instance.id), :headers => headers)

            expect(response).to have_attributes(
              :status => 200,
              :parsed_body => paginated_response(0, [])
            )
          end

          it "failure: with an invalid id" do
            instance = Source.create!(attributes.merge("tenant" => tenant))
            missing_id = (instance.id * 1000)
            expect(Source.exists?(missing_id)).to eq(false)

            get(subcollection_path(missing_id), :headers => headers)

            expect(response).to have_attributes(
              :status => 404,
              :parsed_body => {"errors"=>[{"detail"=>"Record not found", "status"=>404}]}
            )
          end
        end
      end
    end
  end
end
