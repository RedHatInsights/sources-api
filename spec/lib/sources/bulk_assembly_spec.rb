describe Sources::BulkAssembly do
  let(:tenant) { create(:tenant) }

  subject do
    ActsAsTenant.with_tenant(tenant) do
      Sources::BulkAssembly.new(params).process.output
    end
  end

  before do
    # TODO: is there a better way to do this?
    SourceType.seed
    ApplicationType.seed
  end

  context "when creating sources" do
    context "when given only a single source" do
      let(:params) { {:sources => [{:name => "singletest", :type => "amazon"}]} }

      it "creates the source" do
        expect(subject[:sources].map(&:name)).to match_array(%w[singletest])
      end
    end

    context "when given multiple sources" do
      let(:params) do
        {:sources => [
          {:name => "bulktest", :type => "amazon"},
          {:name => "anothertest", :type => "openshift"}
        ]}
      end

      it "creates the source" do
        expect(subject[:sources].map(&:name)).to match_array(%w[bulktest anothertest])
      end
    end

    context "when given a bad source type" do
      let(:params) { {:sources => [{:name => "the bad source", :type => "nothere"}]} }

      it "raises exception" do
        expect { subject }.to raise_error(ActiveRecord::ActiveRecordError)
      end
    end
  end

  context "when creating a source + subresource" do
    let(:sourcehash) { {:sources => [{:name => "mysource", :type => "amazon"}]} }

    context "when the request is well formed" do
      context "with a single endpoint" do
        let(:params) { sourcehash.merge!(:endpoints => [{:host => "example.com", :source_name => "mysource"}]) }

        it "creates a source and endpoint and links them together" do
          output = subject
          src = output[:sources].first
          endpt = output[:endpoints].first

          expect(endpt.source).to eq src
        end
      end

      context "with a single application" do
        let(:params) { sourcehash.merge!(:applications => [{:type => "cost", :source_name => "mysource"}]) }

        it "creates a source and application and links them together" do
          output = subject
          src = output[:sources].first
          application = output[:applications].first

          expect(application.source).to eq src
        end
      end

      context "with an application that has private superkey data" do
        let(:params) do
          sourcehash.merge!(
            :applications => [{:type => "cost", :source_name => "mysource", :extra => {:_superkey => {"guid" => "asdf"}}}]
          )
        end

        it "creates the resources and links them together" do
          output = subject
          src = output[:sources].first
          application = output[:applications].first

          expect(application.source).to eq src
          expect(application.superkey_data).to match(a_hash_including("guid" => "asdf"))
        end
      end

      context "with a single authentication" do
        let(:params) do
          sourcehash.merge!(
            :authentications => [
              {:authtype => "userpass", :username => "user", :password => "pass", :resource_type => "source", :resource_name => "mysource"}
            ]
          )
        end

        it "creates a source and authentication and links them together" do
          output = subject
          src = output[:sources].first
          authentication = output[:authentications].first

          expect(authentication.resource).to eq src
        end
      end

      context "with an endpoint + authentication" do
        let(:params) do
          sourcehash.merge!(
            :endpoints       => [
              {:host => "example.com", :source_name => "mysource"}
            ],
            :authentications => [
              {:authtype => "userpass", :username => "user", :password => "pass", :resource_type => "endpoint", :resource_name => "example.com"}
            ]
          )
        end

        it "creates the resources and links them together" do
          output = subject
          src = output[:sources].first
          endpoint = output[:endpoints].first
          auth = output[:authentications].first

          expect(auth.resource).to eq endpoint
          expect(endpoint.source).to eq src
        end
      end

      context "with an application + authentication" do
        let(:params) do
          sourcehash.merge!(
            :applications    => [
              {:type => "cost", :source_name => "mysource"}
            ],
            :authentications => [
              {:authtype => "arn", :username => "user", :resource_type => "application", :resource_name => "cost"}
            ]
          )
        end

        it "creates the resources and links them together" do
          output = subject
          src = output[:sources].first
          application = output[:applications].first
          auth = output[:authentications].first

          expect(auth.resource).to eq application
          expect(application.source).to eq src
        end
      end

      # This is the big superkey use-case, multiple applications being created off of a single source.
      context "with multiple applications and authentications" do
        let(:params) do
          sourcehash.merge!(
            :applications    => [
              {:type => "cost", :source_name => "mysource"},
              {:type => "cloud-meter", :source_name => "mysource"},
            ],
            :authentications => [
              {:authtype => "arn", :username => "arn1", :resource_type => "application", :resource_name => "cost"},
              {:authtype => "cloud-meter-arn", :username => "arn2", :resource_type => "application", :resource_name => "cloud-meter"}
            ]
          )
        end

        it "links all together appropriately" do
          output = subject
          src = output[:sources].first
          applications = output[:applications]
          authentications = output[:authentications]

          expect(applications.map(&:source).uniq.first).to eq src
          expect(authentications.map(&:resource).uniq).to match_array applications

          applications.each do |app|
            expect(app.authentications.count).to eq 1
          end
        end
      end
    end

    context "when the request is not correct" do
      context "with a source+endpoint request" do
        let(:params) { sourcehash.merge!(:endpoints => [{:host => "example.com", :source_name => "notmatched"}]) }

        it "fails to link" do
          expect { subject }.to raise_error(ActiveRecord::ActiveRecordError)
        end
      end

      context "with a source+application request" do
        let(:params) { sourcehash.merge!(:applications => [{:type => "cost", :source_name => "notmatched"}]) }

        it "fails to link" do
          expect { subject }.to raise_error(ActiveRecord::ActiveRecordError)
        end
      end

      context "with a source+endpoint+authentication request" do
        let(:params) do
          sourcehash.merge!(
            :endpoints       => [{:host => "example.com", :source_name => "mysource"}],
            :authentications => [{:authtype => "arn", :username => "user", :resource_type => "application", :resource_name => "notright"}]
          )
        end

        it "fails to link" do
          expect { subject }.to raise_error(ActiveRecord::ActiveRecordError)
        end
      end

      context "with a source+application+authentication request" do
        let(:params) do
          sourcehash.merge!(
            :applications    => [{:type => "cost", :source_name => "mysource"}],
            :authentications => [{:authtype => "arn", :username => "user", :resource_type => "application", :resource_name => "notright"}]
          )
        end

        it "fails to link" do
          expect { subject }.to raise_error(ActiveRecord::ActiveRecordError)
        end
      end
    end

    context "when creating subresources using an existing source" do
      let(:source) do
        create(:source, :source_type => SourceType.find_by(:name => "amazon"))
      end

      context "when creating an application using an existing source" do
        let(:params) do
          {:applications => [
            {:type => "cost", :source_name => source.name}
          ]}
        end

        it "looks up the source and links it" do
          application = subject[:applications].first

          expect(application.source).to eq source
        end
      end

      context "when creating an endpoint using an exisitng source" do
        let(:params) do
          {:endpoints => [
            {:host => "example.com", :source_name => source.name}
          ]}
        end

        it "looks up the source and links it" do
          endpoint = subject[:endpoints].first

          expect(endpoint.source).to eq source
        end
      end

      context "when creating an application + authentication on an existing source" do
        let(:params) do
          {
            :applications    => [
              {:type => "cost", :source_name => source.name}
            ],
            :authentications => [
              {:authtype => "arn", :username => "an arn", :resource_type => "application", :resource_name => "cost"}
            ]
          }
        end

        it "looks up the source and links everything" do
          output = subject
          application = output[:applications].first
          authentication = output[:authentications].first

          expect(application.source).to eq source
          expect(authentication.source).to eq source
          expect(authentication.resource).to eq application
        end
      end

      context "when creating an endpoint + authentication on an existing source" do
        let(:params) do
          {
            :endpoints       => [
              {:host => "example.com", :source_name => source.name}
            ],
            :authentications => [
              {:authtype => "arn", :username => "an arn", :resource_type => "endpoint", :resource_name => "example.com"}
            ]
          }
        end

        it "looks up the source and links everything" do
          output = subject
          endpoint = output[:endpoints].first
          authentication = output[:authentications].first

          expect(endpoint.source).to eq source
          expect(authentication.source).to eq source
          expect(authentication.resource).to eq endpoint
        end
      end
    end

    context "when creating resources but specifying type id instead of string" do
      context "sources" do
        let(:params) { {:sources => [{:name => "testingsource", :source_type_id => SourceType.first.id}]} }

        it "looks up the source type properly" do
          expect(subject[:sources].first.source_type).to eq SourceType.first
        end
      end

      context "applications" do
        let(:apptype) { ApplicationType.find_by(:name => "/insights/platform/cost-management") }
        let(:params) do
          {
            :sources      => [{:name => "testingsource", :type => "amazon"}],
            :applications => [{:source_name => "testingsource", :application_type_id => apptype}]
          }
        end

        it "looks up the application type properly" do
          expect(subject[:applications].first.application_type).to eq apptype
        end
      end
    end
  end
end
