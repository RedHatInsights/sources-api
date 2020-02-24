RSpec.shared_examples "invalid_url_requests" do |request_type, invalid_url, http_method|
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  context "with invalid #{request_type} URLs" do
    it "fail with an error object" do
      send(http_method, invalid_url, :headers => headers)

      if http_method == :head
        expect(response.status).to eq(404)
      else
        expected_body = {"errors" => [{"detail" => "Invalid URL #{invalid_url} specified.", "status" => 404}]}
        expect(response).to have_attributes(:status => 404, :parsed_body => expected_body)
      end
    end
  end
end

RSpec.describe("Requests") do
  %i[get post head].each do |method|
    include_examples("invalid_url_requests", "api", "/api/v9999/bogus_collection", method)
    include_examples("invalid_url_requests", "internal", "/internal/v9999/unpublished_collection", method)
    include_examples("invalid_url_requests", "", "/bogus_url", method)
  end
end
