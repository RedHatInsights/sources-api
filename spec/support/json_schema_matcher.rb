RSpec::Matchers.define :match_json_schema do |version, schema|
  match do |parsed_body|
    s = ::Insights::API::Common::OpenApi::Docs.instance[version].definitions[schema]
    JSON::Validator.validate!(s, parsed_body)
  end
end
