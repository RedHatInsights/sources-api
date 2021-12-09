module RequestHelper
  DEFAULT_USER = {
    "entitlements" => {
      "ansible"          => {
        "is_entitled" => true
      },
      "hybrid_cloud"     => {
        "is_entitled" => true
      },
      "insights"         => {
        "is_entitled" => true
      },
      "migrations"       => {
        "is_entitled" => true
      },
      "openshift"        => {
        "is_entitled" => true
      },
      "smart_management" => {
        "is_entitled" => true
      }
    },
    "identity"     => {
      "account_number" => "0369233",
      "type"           => "User",
      "auth_type"      => "basic-auth",
      "user"           => {
        "username"     => "jdoe",
        "email"        => "jdoe@acme.com",
        "first_name"   => "John",
        "last_name"    => "Doe",
        "is_active"    => true,
        "is_internal"  => false,
        "locale"       => "en_US"
      },
      "internal"       => {
        "org_id"    => "3340851",
        "auth_time" => 6300
      }
    }
  }.freeze

  def encode(val)
    if val.kind_of?(Hash)
      hashed = val.stringify_keys
      Base64.strict_encode64(hashed.to_json)
    else
      raise StandardError, "Must be a Hash"
    end
  end

  def encoded_user_hash(hash = nil)
    encode(hash || DEFAULT_USER)
  end

  def default_headers
    {'x-rh-identity'            => encoded_user_hash,
     'x-rh-insights-request-id' => 'gobbledygook'}
  end

  def original_url
    "http://example.com"
  end

  def default_request
    {:headers => default_headers, :original_url => original_url}
  end
end
