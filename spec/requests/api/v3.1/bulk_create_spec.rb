describe "v3.1 - /bulk_create" do
  include ::Spec::Support::TenantIdentity

  before do
    # TODO: is there a better way to do this?
    SourceType.seed
    ApplicationType.seed
  end

  let(:client) { instance_double("ManageIQ::Messaging::Client") }
  before do
    allow(client).to receive(:publish_topic)
    allow(Sources::Api::Messaging).to receive(:client).and_return(client)
  end

  let(:amazontype) { SourceType.find_by(:name => "amazon") }
  let(:swatchapp) { ApplicationType.find_by(:name => "/insights/platform/cloud-meter") }
  let(:costapp) { ApplicationType.find_by(:name => "/insights/platform/cost-management") }
  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:collection_path) { "/api/v3.1/bulk_create" }

  describe "/api/v3.1/bulk_create" do
    let(:sources) { {:sources => [{:name => "testsource", :source_type_name => "amazon"}]} }

    context "with source + application" do
      context "with string apptype" do
        it "creates the resources" do
          expect(Sources::Api::Events).to receive(:raise_event).twice

          post collection_path,
               :headers => headers,
               :params  => sources.merge!(
                 :applications => [{:application_type_name => costapp.name, :source_name => "testsource"}]
               ).to_json

          expect(response).to have_attributes(
            :status      => 201,
            :parsed_body => a_hash_including('sources', 'applications')
          )

          source = response.parsed_body["sources"].first
          application = response.parsed_body["applications"].first
          expect(source["source_type_id"]).to eq amazontype.id.to_s
          expect(application["application_type_id"]).to eq costapp.id.to_s
        end
      end

      context "with id apptype" do
        it "creates the resources" do
          expect(Sources::Api::Events).to receive(:raise_event).twice

          post collection_path,
               :headers => headers,
               :params  => sources.merge!(
                 :applications => [{:application_type_id => costapp.id.to_s, :source_name => "testsource"}]
               ).to_json

          expect(response).to have_attributes(
            :status      => 201,
            :parsed_body => a_hash_including('sources', 'applications')
          )

          source = response.parsed_body["sources"].first
          application = response.parsed_body["applications"].first
          expect(source["source_type_id"]).to eq amazontype.id.to_s
          expect(application["application_type_id"]).to eq costapp.id.to_s
        end
      end

      context "with multiple applications" do
        it "creates the resources" do
          expect(Sources::Api::Events).to receive(:raise_event).thrice

          post collection_path,
               :headers => headers,
               :params  => sources.merge!(
                 :applications => [
                   {:application_type_name => costapp.name, :source_name => "testsource"},
                   {:application_type_name => swatchapp.name, :source_name => "testsource"}
                 ]
               ).to_json

          expect(response).to have_attributes(
            :status      => 201,
            :parsed_body => a_hash_including('sources', 'applications')
          )

          source = response.parsed_body["sources"].first
          expect(source["source_type_id"]).to eq amazontype.id.to_s
          apps = response.parsed_body["applications"]
          expect(apps.count).to eq 2
          expect(apps.map { |x| x["application_type_id"].to_i }).to match_array([costapp.id, swatchapp.id])
        end
      end
    end

    context "with source + endpoint" do
      it "creates the resources" do
        expect(Sources::Api::Events).to receive(:raise_event).twice

        post collection_path,
             :headers => headers,
             :params  => sources.merge!(
               :endpoints => [{:host => "example.com", :source_name => "testsource"}]
             ).to_json

        expect(response).to have_attributes(
          :status      => 201,
          :parsed_body => a_hash_including('sources', 'endpoints')
        )

        source = response.parsed_body["sources"].first
        endpoint = response.parsed_body["endpoints"].first
        expect(source["source_type_id"]).to eq amazontype.id.to_s
        expect(endpoint["host"]).to eq "example.com"
      end
    end

    context "with source + application + authentication" do
      it "creates the resources" do
        expect(Sources::Api::Events).to receive(:raise_event).exactly(4).times

        post collection_path,
             :headers => headers,
             :params  => sources.merge!(
               :applications    => [{
                 :application_type_name => costapp.name,
                 :source_name           => "testsource"
               }],
               :authentications => [{
                 :authtype      => "arn",
                 :username      => "testarn",
                 :resource_type => "application",
                 :resource_name => "cost"
               }]
             ).to_json

        expect(response).to have_attributes(
          :status      => 201,
          :parsed_body => a_hash_including('sources', 'applications', 'authentications')
        )

        source = response.parsed_body["sources"].first
        application = response.parsed_body["applications"].first
        authentication = response.parsed_body["authentications"].first
        expect(source["source_type_id"]).to eq amazontype.id.to_s
        expect(application["application_type_id"]).to eq costapp.id.to_s
        expect(authentication["username"]).to eq "testarn"
      end
    end

    context "with source + endpoint + authentication" do
      it "creates the resources" do
        expect(Sources::Api::Events).to receive(:raise_event).thrice

        post collection_path,
             :headers => headers,
             :params  => sources.merge!(
               :endpoints       => [{
                 :host        => "example.com",
                 :source_name => "testsource"
               }],
               :authentications => [{
                 :authtype      => "arn",
                 :username      => "testarn",
                 :resource_type => "endpoint",
                 :resource_name => "example.com"
               }]
             ).to_json

        expect(response).to have_attributes(
          :status      => 201,
          :parsed_body => a_hash_including('sources', 'endpoints', 'authentications')
        )

        source = response.parsed_body["sources"].first
        endpoint = response.parsed_body["endpoints"].first
        authentication = response.parsed_body["authentications"].first
        expect(source["source_type_id"]).to eq amazontype.id.to_s
        expect(endpoint["host"]).to eq "example.com"
        expect(authentication["username"]).to eq "testarn"
      end
    end

    context "with a bad source type" do
      it "throws a 400" do
        post collection_path,
             :headers => headers,
             :params  => {:sources => [{:source_type_name => "nothere", :name => "a bad one"}]}

        expect(response).to have_attributes(:status => 400)
      end
    end

    context "with a bad application type" do
      it "throws a 400" do
        post collection_path,
             :headers => headers,
             :params  => sources.merge!(:applications => [{:source_name => "testsource", :application_type_name => "notcost"}])

        expect(response).to have_attributes(:status => 400)
      end
    end

    context "with a bad endpoint source link" do
      it "throws a 400" do
        post collection_path,
             :headers => headers,
             :params  => sources.merge!(:endpoints => [{:source_name => "nothere"}])

        expect(response).to have_attributes(:status => 400)
      end
    end

    context "with a bad application source link" do
      it "throws a 400" do
        post collection_path,
             :headers => headers,
             :params  => sources.merge!(:applications => [{:source_name => "nothere"}])

        expect(response).to have_attributes(:status => 400)
      end
    end

    context "with a bad authentication link to endpoint" do
      it "throws a 400" do
        post collection_path,
             :headers => headers,
             :params  => sources.merge!(:endpoints => [{:source_name => "testsource", :host => "goodone.com"}], :authentications => [{:resource_type => "applications", :resource_name => "nothere"}])

        expect(response).to have_attributes(:status => 400)
      end
    end

    context "with a bad authentication link to application" do
      it "throws a 400" do
        post collection_path,
             :headers => headers,
             :params  => sources.merge!(:applications => [{:source_name => "testsource"}], :authentications => [{:resource_type => "applications", :resource_name => "nothere"}])

        expect(response).to have_attributes(:status => 400)
      end
    end
  end
end
