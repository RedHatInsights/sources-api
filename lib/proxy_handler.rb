class ProxyHandler
  def self.proxy_mapping
    @proxy_mapping ||= if File.file?("./proxy_rules/rules.json")
                         JSON.parse(File.read("./proxy_rules/rules.json"))
                       else
                         Hash.new([])
                       end
  end

  def self.enabled?
    ENV["PROXY_REQUESTS"] == "true"
  end

  def self.go_svc
    @go_svc ||= "http://#{ENV["GO_SVC"] || "sources-api-go"}:#{ENV["GO_PORT"] || 8000}"
  end

  def self.should_proxy?(action, controller)
    # proxy on 3 rules:
    # 1. enabled in the ENV
    # 2. route is enabled in the config
    # 3. route is the "latest" version, can remove this once we support "all" versions on the Go sdie
    enabled? && proxy_mapping[controller.split("/").last]&.include?(action) && controller.split("/")[1] == "v3x1"
  end

  def self.proxy_request(request, headers)
    case request.method
    when "GET", "DELETE"
      Faraday.send(request.method.downcase, "#{go_svc}#{CGI.unescape(request.fullpath)}") do |req|
        req.headers = headers
      end
    when "POST", "PATCH"
      Faraday.send(request.method.downcase, "#{go_svc}#{CGI.unescape(request.fullpath)}") do |req|
        # we need to include the content-type header because by default faraday
        # encodes the request body as x-www-form-urlencoded
        req.headers = headers.merge!("Content-Type" => "application/json")
        req.body = request.body.read
      end
    else
      raise "unsupported proxy operation #{request.method}"
    end
  end
end
