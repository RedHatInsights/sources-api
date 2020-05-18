RSpec.describe("v1.0 - ApplicationTypes") do
  include ::Spec::Support::TenantIdentity

  let(:headers)         { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:attributes)      { {"name" => "my application type"} }
  let(:collection_path) { "/api/v1.0/application_types" }

  describe("/api/v1.0/application_types") do
    context "get" do
      it "success: empty collection" do
        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        ApplicationType.create!(attributes)

        get(collection_path, :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes)])
        )
      end
    end
  end

  describe("/api/v1.0/application_types/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = ApplicationType.create!(attributes)

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s))
        )
      end

      it "failure: with an invalid id" do
        instance = ApplicationType.create!(attributes)

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors" => [{"detail" => "Record not found", "status" => "404"}]}
        )
      end
    end
  end

  describe("subcollections") do
    existing_subcollections = [
      "sources",
    ]

    existing_subcollections.each do |subcollection|
      describe("/api/v1.0/application_types/:id/#{subcollection}") do
        let(:subcollection) { subcollection }

        def subcollection_path(id)
          File.join(collection_path, id.to_s, subcollection)
        end

        context "get" do
          it "success: with a valid id" do
            instance = ApplicationType.create!(attributes)

            get(subcollection_path(instance.id), :headers => headers)

            expect(response).to have_attributes(
              :status      => 200,
              :parsed_body => paginated_response(0, [])
            )
          end

          it "failure: with an invalid id" do
            instance   = ApplicationType.create!(attributes)
            missing_id = (instance.id * 1000)
            expect(ApplicationType.exists?(missing_id)).to eq(false)

            get(subcollection_path(missing_id), :headers => headers)

            expect(response).to have_attributes(
              :status      => 404,
              :parsed_body => {"errors" => [{"detail" => "Record not found", "status" => "404"}]}
            )
          end
        end
      end
    end
  end
end
