class VaultInterface
  GO_SVC_URL = "http://#{ENV["GO_SVC"]}:#{ENV["GO_PORT"]}/api/sources/v3.1/authentications".freeze

  attr_reader :authentication, :response

  def initialize(authentication)
    raise "need Go svc" unless ENV["GO_SVC"] && ENV["GO_PORT"]

    @authentication = authentication
  end

  def process
    resp = Faraday.new(GO_SVC_URL).post do |req|
      req["content-type"] = "application/json"
      req["x-rh-sources-account-number"] = @authentication.tenant.external_tenant
      req["x-rh-sources-psk"] = ENV["INTERNAL_PSK"]

      req.body = {
        :resource_type             => @authentication.resource_type,
        :resource_id               => @authentication.resource_id,
        :name                      => @authentication.name,
        :authtype                  => @authentication.authtype,
        :username                  => @authentication.username,
        :password                  => @authentication.password,
        :extra                     => @authentication.extra,
        :availability_status       => @authentication.availability_status,
        :availability_status_error => @authentication.availability_status_error,
        :last_checked_at           => @authentication.last_checked_at,
        :last_available_at         => @authentication.last_available_at,
        :paused_at                 => @authentication.paused_at
      }.to_json
    end

    parsed = JSON.parse(resp.body)

    raise "failed to post authentication [#{@authentication.id}] to vault: #{parsed}" if resp.status != 201

    uid = parsed["id"]
    @authentication.application_authentications.each do |appauth|
      appauth.update!(:vault_path => "#{@authentication.resource_type}_#{authentication.resource_id}_#{uid}")
    end
  end
end
