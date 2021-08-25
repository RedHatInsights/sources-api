require "webmock/rspec"

RSpec.describe("v3.1 - Sources") do
  include ::Spec::Support::TenantIdentity

  let(:headers)         { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:attributes)      { {"name" => "my source", "source_type_id" => source_type.id.to_s} }
  let(:collection_path) { "/api/v3.1/sources" }
  let(:source_type)     { create(:source_type, :name => "SourceType", :vendor => "Some Vendor", :product_name => "Product Name") }
  let(:client) { instance_double(ManageIQ::Messaging::Client) }
  before do
    allow(Sources::Api::Messaging).to receive(:client).and_return(client)
    allow(client).to receive(:publish_topic)
  end

  describe("/api/v3.1/sources") do
    context "get" do
      context "user credentials" do
        it "success: empty collection" do
          get(collection_path, :headers => headers)

          expect(response).to have_attributes(
            :status      => 200,
            :parsed_body => paginated_response(0, [])
          )
        end

        it "success: non-empty collection" do
          create(:source, attributes.merge("tenant" => tenant))

          get(collection_path, :headers => headers)

          expect(response).to have_attributes(
            :status      => 200,
            :parsed_body => paginated_response(1, [a_hash_including(attributes)])
          )
        end
      end

      context "system credentials" do
        let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => system_identity} }

        it "success: empty collection" do
          get(collection_path, :headers => headers)

          expect(response).to have_attributes(
            :status      => 200,
            :parsed_body => paginated_response(0, [])
          )
        end

        it "success: non-empty collection" do
          create(:source, attributes.merge("tenant" => tenant))

          get(collection_path, :headers => headers)

          expect(response).to have_attributes(
            :status      => 200,
            :parsed_body => paginated_response(1, [a_hash_including(attributes)])
          )
        end
      end
    end

    context "post" do
      it "success: with valid body" do
        post(collection_path, :params => attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v3.1/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(attributes)
        )
      end

      it "failure: with a missing name attribute" do
        post(collection_path, :params => attributes.except("name").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "Invalid parameter - Validation failed: Name can't be blank").to_h
        )
      end

      it "failure: with extra attributes" do
        post(collection_path, :params => attributes.merge("aaa" => "bbb").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/Source does not define properties: aaa").to_h
        )
      end

      it "failure: with a blank name attribute" do
        post(collection_path, :params => attributes.merge("name" => "").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "Invalid parameter - Validation failed: Name can't be blank").to_h
        )
      end

      it "failure: with a null name attribute" do
        post(collection_path, :params => attributes.merge("name" => nil).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::NotNullError: #/components/schemas/Source/properties/name does not allow null values").to_h
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => attributes.merge("source_type_id" => "xxx").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::InvalidPattern: #/components/schemas/ID pattern ^\\d+$ does not match value: xxx").to_h
        )
      end

      it "failure: with a duplicate name in the same tenant" do
        2.times do
          post(collection_path, :params => attributes.to_json, :headers => headers)
        end

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add(
            "400", "Invalid parameter - Validation failed: Name has already been taken"
          ).to_h
        )
      end

      it "success: with a duplicate name in a different tenant" do
        post(collection_path, :params => attributes.to_json, :headers => headers)

        second_tenant = rand(1000).to_s
        second_identity = {"x-rh-identity" => Base64.encode64({"identity" => {"account_number" => second_tenant, "user" => {"is_org_admin" => true}}}.to_json)}
        post(collection_path, :params => attributes.to_json, :headers => headers.merge(second_identity))

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v3.1/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(attributes)
        )
      end

      it "failure: with a not unique UID" do
        post(collection_path, :params => attributes.merge("name" => "aaa", "uid" => "123").to_json, :headers => headers)
        post(collection_path, :params => attributes.merge("name" => "abc", "uid" => "123").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "Record not unique").to_h
        )
      end

      context "with system credentials" do
        let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => system_identity} }

        it "success: with valid body" do
          post(collection_path, :params => attributes.to_json, :headers => headers)

          expect(response).to have_attributes(
            :status      => 201,
            :location    => "http://www.example.com/api/v3.1/sources/#{response.parsed_body["id"]}",
            :parsed_body => a_hash_including(attributes)
          )
        end
      end
    end
  end

  describe("/api/v3.1/sources/:id") do
    context "get" do
      it "success: with a valid id" do
        instance = create(:source, attributes.merge("tenant" => tenant))

        get(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 200,
          :parsed_body => a_hash_including(attributes.merge("id" => instance.id.to_s))
        )
      end

      it "failure: with an invalid id" do
        instance = create(:source, attributes.merge("tenant" => tenant))

        get(instance_path(instance.id * 1000), :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors"=>[{"detail" => "Record not found", "status" => "404"}]}
        )
      end
    end

    context "patch" do
      it "success: with a valid id" do
        instance = create(:source, attributes.merge("tenant" => tenant))
        new_attributes = {"name" => "new name"}

        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 204,
          :parsed_body => ""
        )

        expect(instance.reload).to have_attributes(new_attributes)
      end

      it "failure: with a null value" do
        instance = create(:source, attributes.merge("tenant" => tenant))
        new_attributes = {"name" => nil}

        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :parsed_body => {"errors"=>[{"detail" => "OpenAPIParser::NotNullError: #/components/schemas/Source/properties/name does not allow null values", "status" => "400"}]}
        )

        expect(instance.reload).to have_attributes(:name => "my source")
      end

      it "failure: with an invalid id" do
        instance = create(:source, attributes.merge("tenant" => tenant))
        new_attributes = {"name" => "new name"}

        patch(instance_path(instance.id * 1000), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors"=>[{"detail" => "Record not found", "status" => "404"}]}
        )
      end

      it "failure: with extra parameters" do
        instance = create(:source, attributes.merge("tenant" => tenant))
        new_attributes = {"aaaaa" => "bbbbb"}

        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :parsed_body => {"errors" => [{"detail" => "OpenAPIParser::NotExistPropertyDefinition: #/components/schemas/Source does not define properties: aaaaa", "status" => "400"}]}
        )
      end

      it "failure: with read-only parameters" do
        instance = create(:source, attributes.merge("tenant" => tenant))
        new_attributes = {"uid" => "xxxxx", "app_creation_workflow" => "manual_configuration"}

        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :parsed_body => {"errors" => [{"detail" => "ActionController::UnpermittedParameters: found unpermitted parameters: :uid, :app_creation_workflow", "status" => "400"}]}
        )
      end

      it "failure: with an invalid attribute value" do
        post(collection_path, :params => attributes.merge("source_type_id" => 4).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "OpenAPIParser::ValidateError: #/components/schemas/ID expected string, but received Integer: 4").to_h
        )
      end

      it "failure: with an invalid availability_status value" do
        post(collection_path, :params => attributes.merge("availability_status" => "bogus").to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :location    => nil,
          :parsed_body => Insights::API::Common::ErrorDocument.new.add("400", "Invalid parameter - Validation failed: Availability status is not included in the list").to_h
        )
      end

      it "success: with an available availability_status" do
        included_attributes = {"name" => "availability_source", "availability_status" => "available"}

        post(collection_path, :params => attributes.merge(included_attributes).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v3.1/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(included_attributes)
        )
      end

      it "success: with a partially_available availability_status" do
        included_attributes = {"name" => "availability_source", "availability_status" => "partially_available"}

        post(collection_path, :params => attributes.merge(included_attributes).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v3.1/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(included_attributes)
        )
      end

      it "success: with an unavailable availability_status" do
        included_attributes = {"name" => "availability_source", "availability_status" => "unavailable"}

        post(collection_path, :params => attributes.merge(included_attributes).to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 201,
          :location    => "http://www.example.com/api/v3.1/sources/#{response.parsed_body["id"]}",
          :parsed_body => a_hash_including(included_attributes)
        )
      end

      it "rejects read_only attributes" do
        instance = create(:source, attributes.merge("tenant" => tenant))
        new_attributes = {"name" => "new name", "created_at" => Time.now.utc}

        patch(instance_path(instance.id), :params => new_attributes.to_json, :headers => headers)

        expect(response).to have_attributes(
          :status      => 400,
          :parsed_body => {"errors" => [{"detail" => "ActionController::UnpermittedParameters: found unpermitted parameter: :created_at", "status" => "400"}]}
        )
      end

      context "paused resources" do
        include_examples "updating paused resource", Source
      end
    end

    context "delete" do
      it "success: with a valid id" do
        instance = create(:source, attributes.merge("tenant" => tenant))

        expect(Sources::Api::Events).to receive(:raise_event).once
        delete(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 204,
          :parsed_body => ""
        )
      end

      it "success: with associated applications" do
        source_type = create(:source_type, :name => "openshift", :vendor => "RedHat", :product_name => "OpenShift")
        attributes  = {"name" => "my_source", "source_type_id" => source_type.id.to_s}
        instance    = create(:source, attributes.merge("tenant" => tenant))

        app_type1 = create(:application_type,
                           :name                   => "/platform/application-type1",
                           :display_name           => "Application Type One",
                           :supported_source_types => ["openshift"])

        app_type2 = create(:application_type,
                           :name                   => "ApplicationType2",
                           :display_name           => "Application Type Two",
                           :supported_source_types => ["openshift"])

        app_type1_url = "http://app1.example.com:8001/availability_check"
        app_type2_url = "http://app2.example.com:8002/availability_check"

        create(:application, :application_type => app_type1, :source => instance, :tenant => tenant)
        create(:application, :application_type => app_type2, :source => instance, :tenant => tenant)

        tenant_payload = {
          "host"                  => "example.com",
          "port"                  => 443,
          "role"                  => "default",
          "path"                  => "api",
          "source_id"             => instance.id.to_s,
          "scheme"                => "https",
          "verify_ssl"            => true,
          "certificate_authority" => "-----BEGIN CERTIFICATE-----\nabcd\n-----END CERTIFICATE-----",
        }

        create(:endpoint, tenant_payload.merge(:tenant => tenant, :source => instance))

        expect(Sources::Api::Events).to receive(:raise_event).exactly(4).times
        delete(instance_path(instance.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 204,
          :parsed_body => ""
        )
        expect(Application.count).to eq(0)
      end
    end
  end

  describe("/api/v3.1/sources/:id/check_availability") do
    let(:openshift_topic)   { "platform.topological-inventory.operations-openshift" }
    let(:amazon_topic)      { "platform.topological-inventory.operations-amazon" }

    def check_availability_path(source_id)
      File.join(collection_path, source_id.to_s, "check_availability")
    end

    context "post" do
      it "failure: with an invalid id" do
        post(check_availability_path(99_999), :headers => headers)

        expect(response).to have_attributes(
          :status      => 404,
          :parsed_body => {"errors"=>[{"detail" => "Record not found", "status" => "404"}]}
        )
      end

      it "success: with valid openshift source and endpoint" do
        source_type = create(:source_type, :name => "openshift", :vendor => "RedHat", :product_name => "OpenShift")
        attributes  = {"name" => "my_source", "source_type_id" => source_type.id.to_s}
        source      = create(:source, attributes.merge("tenant" => tenant))
        _endpoint   = create(:endpoint, :source => source, :tenant => tenant)

        expect(KafkaPublishJob).to receive(:perform_later).with(
          openshift_topic,
          "Source.availability_check",
          a_hash_including(
            :params => a_hash_including(
              :source_id       => source.id.to_s,
              :external_tenant => tenant.external_tenant
            )
          )
        )

        post(check_availability_path(source.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 202,
          :parsed_body => {}
        )
      end

      it "success: with valid amazon source" do
        source_type = create(:source_type, :name => "amazon", :vendor => "Amazon", :product_name => "Amazon Web Services")
        attributes  = {"name" => "my_source", "source_type_id" => source_type.id.to_s}
        source      = create(:source, attributes.merge("tenant" => tenant))
        _endpoint   = create(:endpoint, :source => source, :tenant => tenant)

        expect(KafkaPublishJob).to receive(:perform_later).with(
          amazon_topic,
          "Source.availability_check",
          a_hash_including(
            :params => a_hash_including(
              :source_id       => source.id.to_s,
              :external_tenant => tenant.external_tenant
            )
          )
        )

        post(check_availability_path(source.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 202,
          :parsed_body => {}
        )
      end

      it "success: with a source-type that topology doesn't support" do
        source_type = create(:source_type, :name => "vsphere", :vendor => "VMware", :product_name => "VMware vSphere")
        attributes  = {"name" => "my_source", "source_type_id" => source_type.id.to_s}
        source      = create(:source, attributes.merge("tenant" => tenant))

        post(check_availability_path(source.id), :headers => headers)

        expect(response).to have_attributes(
          :status      => 202,
          :parsed_body => {}
        )
      end

      it "success: with valid openshift source querying associated applications" do
        source_type = create(:source_type, :name => "openshift", :vendor => "RedHat", :product_name => "OpenShift")
        attributes  = {"name" => "my_source", "source_type_id" => source_type.id.to_s}
        source      = create(:source, attributes.merge("tenant" => tenant))

        app_type1 = create(:application_type,
                           :name                   => "/platform/application-type1",
                           :display_name           => "Application Type One",
                           :supported_source_types => ["openshift"])

        app_type2 = create(:application_type,
                           :name                   => "ApplicationType2",
                           :display_name           => "Application Type Two",
                           :supported_source_types => ["openshift"])

        app_type1_url = "http://app1.example.com:8001/availability_check"
        app_type2_url = "http://app2.example.com:8002/availability_check"

        app1 = create(:application, :application_type => app_type1, :source => source, :tenant => tenant)
        app2 = create(:application, :application_type => app_type2, :source => source, :tenant => tenant)

        source.applications = [app1, app2]

        expect(KafkaPublishJob).not_to receive(:perform_later)

        request_body = {:source_id => source.id.to_s}.to_json

        stub_request(:post, app_type1_url)
          .with do |request|
            request.headers = headers
            request.body    = request_body
          end
          .to_return(:status => 200, :body => "")

        stub_request(:post, app_type2_url)
          .with do |request|
            request.headers = headers
            request.body    = request_body
          end
          .to_return(:status => 200, :body => "")

        ENV["APPLICATION_TYPE1_AVAILABILITY_CHECK_URL"] = app_type1_url
        ENV["APPLICATIONTYPE2_AVAILABILITY_CHECK_URL"]  = app_type2_url

        post(check_availability_path(source.id), :headers => headers)

        assert_requested(:post,
                         app_type1_url,
                         :headers => headers,
                         :body    => request_body,
                         :times   => 1)
        assert_requested(:post,
                         app_type2_url,
                         :headers => headers,
                         :body    => request_body,
                         :times   => 1)

        expect(response).to have_attributes(
          :status      => 202,
          :parsed_body => {}
        )
      end
    end
  end

  describe "pausing" do
    let!(:instance) { create(:source, :paused_at => paused_at, :tenant => tenant) }

    def expect_pausable_relations(check_method)
      instance.reload
      expect(instance.send(check_method)).to be_truthy
      expect(instance.endpoints.map(&check_method).all?).to be_truthy
      expect(instance.applications.map(&check_method).all?).to be_truthy
      authentications = instance.applications.map(&:authentications).flatten
      expect(authentications.map(&check_method).all?).to be_truthy
      authentications = instance.applications.map(&:application_authentications).flatten
      expect(authentications.map(&check_method).all?).to be_truthy
    end

    before do
      # TODO: fix the factory for application
      application = Application.create!(
        :application_type => create(:application_type),
        :source           => instance,
        :paused_at        => paused_at,
        :tenant           => instance.tenant
      )
      payload =  {
        "username"      => "test_name",
        "password"      => "Test Password",
        "resource_type" => "Application",
        "resource_id"   => application.id.to_s
      }

      instance.endpoints << create(:endpoint)
      instance.applications.first.authentications << create(:authentication, payload.merge(:tenant => tenant))
    end

    describe "POST /sources/:id/pause" do
      let(:paused_at) { nil }

      before do
        instance.undiscard
        instance.applications.each { |x| x.send(:undiscard_workflow) }
      end

      it "pauses the source" do
        expect(AvailabilityMessageJob).to receive(:perform_later).with("Application.pause", anything, anything).once

        expect_pausable_relations(:undiscarded?)

        post("#{instance_path(instance.id)}/pause", :headers => headers)

        expect(response.status).to eq 204

        instance.reload

        expect(instance.paused_at).to be_truthy
        expect_pausable_relations(:discarded?)
      end
    end

    describe "POST /applications/:id/unpause" do
      let(:paused_at) { Time.current }

      before do
        instance.discard
        instance.applications.each { |x| x.send(:discard_workflow) }
      end

      it "un-pauses the application" do
        expect(AvailabilityMessageJob).to receive(:perform_later).with("Application.unpause", anything, anything).exactly(1).time
        expect_pausable_relations(:discarded?)

        post("#{instance_path(instance.id)}/unpause", :headers => headers)

        expect(response.status).to eq 202

        instance.reload

        expect(instance.paused_at).to be_falsey
        expect_pausable_relations(:undiscarded?)
      end
    end
  end

  describe("subcollections") do
    existing_subcollections = [
      "endpoints",
    ]

    existing_subcollections.each do |subcollection|
      describe("/api/v3.1/sources/:id/#{subcollection}") do
        let(:subcollection) { subcollection }

        def subcollection_path(id)
          File.join(collection_path, id.to_s, subcollection)
        end

        context "get" do
          it "success: with a valid id" do
            instance = create(:source, attributes.merge("tenant" => tenant))

            get(subcollection_path(instance.id), :headers => headers)

            expect(response).to have_attributes(
              :status      => 200,
              :parsed_body => paginated_response(0, [])
            )
          end

          it "failure: with an invalid id" do
            instance = create(:source, attributes.merge("tenant" => tenant))
            missing_id = (instance.id * 1000)
            expect(Source.exists?(missing_id)).to eq(false)

            get(subcollection_path(missing_id), :headers => headers)

            expect(response).to have_attributes(
              :status      => 404,
              :parsed_body => {"errors"=>[{"detail" => "Record not found", "status" => "404"}]}
            )
          end
        end
      end
    end
  end

  def instance_path(id)
    File.join(collection_path, id.to_s)
  end
end
