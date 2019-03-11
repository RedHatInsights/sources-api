RSpec.describe("v0.1 - ContainerGroups") do
  let(:attributes)        { {"container_node_id" => container_node.id.to_s, "container_project_id" => container_project.id.to_s, "source_id" => source.id.to_s, "tenant_id" => tenant.id.to_s, "source_ref" => SecureRandom.uuid} }
  let(:collection_path)   { "/api/v0.1/container_groups" }
  let(:container_node)    { ContainerNode.create!(:tenant => tenant, :source => source, :source_ref => SecureRandom.uuid) }
  let(:container_project) { ContainerProject.create!(:tenant => tenant, :source => source, :source_ref => SecureRandom.uuid) }
  let(:source)            { Source.create!(:name => "name", :source_type => source_type, :tenant => tenant) }
  let(:source_type)       { SourceType.create!(:vendor => "vendor", :product_name => "product_name", :name => "name") }
  let(:tenant)            { Tenant.create! }

  describe("/api/v0.1/container_groups") do
    context "get" do
      it "success: empty collection" do
        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "success: non-empty collection" do
        ContainerGroup.create!(attributes)

        get(collection_path)

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(1, [a_hash_including(attributes.except("tenant_id"))])
        )
      end
    end
  end

  describe("/api/v0.1/container_groups/:id") do
    def instance_path(id)
      File.join(collection_path, id.to_s)
    end

    context "get" do
      it "success: with a valid id" do
        instance = ContainerGroup.create!(attributes)

        get(instance_path(instance.id))

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s).except("tenant_id"))
        )
      end

      it "failure: with an invalid id" do
        instance = ContainerGroup.create!(attributes)

        get(instance_path(instance.id * 1000))

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => ""
        )
      end
    end
  end

  describe("/api/v0.1/container_groups/:id/containers") do
    def subcollection_path(id, subcollection)
      File.join(collection_path, id.to_s, subcollection)
    end

    context "get" do
      it "success: with a valid id" do
        instance = ContainerGroup.create!(attributes)

        get(subcollection_path(instance.id, "containers"))

        expect(response).to have_attributes(
          :status => 200,
          :parsed_body => paginated_response(0, [])
        )
      end

      it "failure: with an invalid id" do
        instance = ContainerGroup.create!(attributes)
        missing_id = (instance.id * 1000)
        expect(Source.exists?(missing_id)).to eq(false)

        get(subcollection_path(missing_id, "containers"))

        expect(response).to have_attributes(
          :status => 404,
          :parsed_body => {"errors"=>[{"detail"=>"Couldn't find ContainerGroup with 'id'=#{missing_id}", "status"=>404}]}
        )
      end
    end
  end
end
