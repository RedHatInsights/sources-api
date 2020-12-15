RSpec.describe("v1.0 - GraphQL") do
  include ::Spec::Support::TenantIdentity
  let!(:source) { create(:source, :tenant => tenant, :name => "sample_source", :uid => "123") }

  let!(:graphql_source_query) { { "query" => "{ sources(id: \"#{source.id}\") { tenant } }" }.to_json }

  def result_source_tenant(response_body)
    JSON.parse(response_body).fetch_path("data", "sources").collect { |source| source["tenant"] }
  end

  context "querying source tenant" do
    before { stub_const("ENV", "BYPASS_TENANCY" => nil) }

    it "returns the external tenant identifier" do
      headers = {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity}

      post("/api/v1.0/graphql", :headers => headers, :params => graphql_source_query)

      expect(response.status).to eq(200)
      expect(result_source_tenant(response.body)).to match_array([tenant.external_tenant])
    end

    it "with non-org-admin: returns the external tenant identifier" do
      headers = {"CONTENT_TYPE" => "application/json", "x-rh-identity" => non_org_admin_identity}

      post("/api/v1.0/graphql", :headers => headers, :params => graphql_source_query)

      expect(response.status).to eq(200)
      expect(result_source_tenant(response.body)).to match_array([tenant.external_tenant])
    end
  end

  context "limits and offsets for root elements" do
    let!(:source2) { create(:source, :tenant => tenant, :name => "sample_source2", :uid => "1234") }
    let!(:source3) { create(:source, :tenant => tenant, :name => "sample_source3", :uid => "12345") }
    let!(:source4) { create(:source, :tenant => tenant, :name => "sample_source4", :uid => "123456") }

    before do
      headers = {"CONTENT_TYPE" => "application/json", "x-rh-identity" => non_org_admin_identity}

      post("/api/v1.0/graphql", :headers => headers, :params => graphql_source_query)
    end

    context 'limit' do
      let(:graphql_source_query) { {"query" => "{ sources(limit:2) { name, id, uid } }"}.to_json }

      it 'works properly' do
        expected_result = {
          "data" => {
            "sources" => [
              {"name" => source.name, "id" => source.id.to_s, "uid" => source.uid.to_s},
              {"name" => source2.name, "id" => source2.id.to_s, "uid" => source2.uid.to_s}
            ]
          },
          "meta" => {"count" => {"sources" => 4}}
        }
        expect(response.status).to eq(200)

        result = JSON.parse(response.body)
        expect(result).to eq(expected_result)
      end
    end

    context 'offset' do
      let(:graphql_source_query) { {"query" => "{ sources(offset:2) { name, id, uid } }"}.to_json }

      it 'works properly' do
        expected_result = {
          "data" => {
            "sources" => [
              {"name" => source3.name, "id" => source3.id.to_s, "uid" => source3.uid.to_s},
              {"name" => source4.name, "id" => source4.id.to_s, "uid" => source4.uid.to_s}
            ]
          },
          "meta" => {"count" => {"sources" => 4}}
        }
        expect(response.status).to eq(200)

        result = JSON.parse(response.body)
        expect(result).to eq(expected_result)
      end
    end

    context 'limit and offset' do
      context 'single root element' do
        let(:graphql_source_query) { {"query" => "{ sources(offset:1, limit:2) { name, id, uid } }"}.to_json }

        it 'works properly' do
          expected_result = {
            "data" => {
              "sources" => [
                {"name" => source2.name, "id" => source2.id.to_s, "uid" => source2.uid.to_s},
                {"name" => source3.name, "id" => source3.id.to_s, "uid" => source3.uid.to_s}
              ]
            },
            "meta" => {"count" => {"sources" => 4}}
          }
          expect(response.status).to eq(200)

          result = JSON.parse(response.body)
          expect(result).to eq(expected_result)
        end
      end
    end
  end
end
