RSpec.describe("v1 redirects") do
  let(:expected_version) { "v1.0" }

  describe("/api/v1") do
    it "redirects to the latest minor version" do
      get("/api/v1/sources")
      expect(response.status).to eq(302)
      expect(response.headers["Location"]).to eq("/api/#{expected_version}/sources")
    end

    it "preserves the openapi.json file extension when using a redirect" do
      get("/api/v1/openapi.json")
      expect(response.status).to eq(302)
      expect(response.headers["Location"]).to eq("/api/#{expected_version}/openapi.json")
    end

    it "preserves the openapi.json file extension when not using a redirect" do
      get("/api/#{expected_version}/openapi.json")
      expect(response.status).to eq(200)
      expect(response.headers["Location"]).to be_nil
    end

    it "direct request doesn't break sources" do
      get("/api/#{expected_version}/sources")
      expect(response.status).to eq(200)
      expect(response.headers["Location"]).to be_nil
    end
  end
end
