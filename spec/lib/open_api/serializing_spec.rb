RSpec.describe("Serializing ApplicationRecord instances to JSON") do
  let(:base_class) { Class.new.tap { |c| c.prepend(OpenApi::Serializer) } }

  context "Encrypted attributes are not in the JSON response" do
    it "on a model that has encrypted columns" do
      model = Class.new(base_class) do
        def self.encrypted_columns
          ["secret"]
        end

        def to_hash
          {"a" => 1, "b" => 2, "secret" => "value"}
        end
      end

      expect(model.new.as_json).to eq("a" => 1, "b" => 2)
    end

    it "on a model that does not have encrypted columns" do
      model = Class.new(base_class) do
        def to_hash
          {"a" => 1, "b" => 2, "secret" => "value"}
        end
      end

      expect(model.new.as_json).to eq("a" => 1, "b" => 2, "secret" => "value")
    end
  end

  it "properly detects the version to serialize for" do
    expect(base_class.new.api_version_from_prefix("api/v0.0/")).to eq("0.0")
    expect(base_class.new.api_version_from_prefix("api/v0.0/something")).to eq("0.0")
    expect(base_class.new.api_version_from_prefix("api/v0.1/something")).to eq("0.1")
    expect(base_class.new.api_version_from_prefix("/api/v0.1/something")).to eq("0.1")
    expect(base_class.new.api_version_from_prefix("a/b/v/v0.1/something")).to eq("0.1")
    expect(base_class.new.api_version_from_prefix("/a/b/v/v0.1/something")).to eq("0.1")
  end
end
