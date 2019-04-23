RSpec.describe("Sources Filtering") do
  include ::Spec::Support::TenantIdentity

  let(:headers)           { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:api_version)       { "v1.0" }
  let(:source_collection) { "/api/#{api_version}/sources" }
  let(:source_type)       { SourceType.create!(:name => "SampleSourceType", :vendor => "Sample Vendor", :product_name => "Sample Product Name") }

  def create_source(source_name, opt_params = {})
    Source.create!({:name => source_name, :source_type_id => source_type.id, :tenant => tenant}.merge(opt_params))
  end

  def expect_success(query, *results)
    get("#{source_collection}?#{query}", :headers => headers)

    expect(response).to(
      have_attributes(
        :parsed_body => paginated_response(results.length, results.collect { |i| a_hash_including("id" => i.id.to_s) }),
        :status      => 200,
      )
    )
  end

  def expect_failure(query, *errors)
    get("#{source_collection}?#{query}", :headers => headers)

    expect(response).to(
      have_attributes(
        :parsed_body => { "errors" => errors.collect { |e| {"detail" => e, "status" => 400} } },
        :status      => 400,
      )
    )
  end

  context "filtering" do
    let!(:source_1) { create_source("aaa", :version => "1") }
    let!(:source_2) { create_source("bbb", :version => "1") }
    let!(:source_3) { create_source("abc") }
    let!(:source_4) { create_source("ddd", :version => "2") }

    it("name:eq single without 'eq' key")          { expect_success("filter[name]=#{source_1.name}", source_1) }
    it("name:eq array of values without 'eq' key") { expect_success("filter[name][]=#{source_1.name}&filter[name][]=#{source_2.name}", source_1, source_2) }
    it("name:eq single with 'eq' key")             { expect_success("filter[name][eq]=#{source_1.name}", source_1) }
    it("name:eq array of values with 'eq' key")    { expect_success("filter[name][eq][]=#{source_1.name}&filter[name][eq][]=#{source_2.name}", source_1, source_2) }

    it("name:contains single")                     { expect_success("filter[name][contains]=a", source_1, source_3) }
    it("name:contains array")                      { expect_success("filter[name][contains][]=a&filter[name][contains][]=b", source_3) }

    it("name:ends_with")                           { expect_success("filter[name][ends_with]=a", source_1) }
    it("name:starts_with")                         { expect_success("filter[name][starts_with]=b", source_2) }

    it("version:nil")                              { expect_success("filter[version][nil]", source_3) }
    it("version:not_nil")                          { expect_success("filter[version][not_nil]", source_1, source_2, source_4) }
  end

  context "error cases" do
    let!(:source_1) { create_source("aaa", :version => "1") }
    let!(:source_2) { create_source("bbb") }

    it("empty filter")      { expect_failure("filter", "found unpermitted parameter: :filter") }
    it("unknown attribute") { expect_failure("filter[xxx]", "found unpermitted parameter: xxx") }

    it "invalid attribute" do
      get("#{source_collection}?filter[bogus_attribute]=a", :headers => headers)

      expect(response.status).to(eq(400))
      expect(response.parsed_body["errors"]).to(eq([{"detail" => "found unpermitted parameter: bogus_attribute", "status" => 400}]))
    end
  end
end
