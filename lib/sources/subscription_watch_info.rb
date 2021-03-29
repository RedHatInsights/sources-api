module Sources
  class SubscriptionWatchInfo
    X_RH_ID = Base64.strict_encode64({:identity => {:account_number => "12345", :user => {:is_org_admin => true}}}.to_json).freeze

    def self.data
      @data ||= begin
        cloudigrade_url = URI.parse(ENV["CLOUD_METER_AVAILABILITY_CHECK_URL"])
        uri = URI.parse("http://#{cloudigrade_url.host}/api/cloudigrade/v2/sysconfig/")

        req = Net::HTTP::Get.new(uri)
        req["x-rh-identity"] = X_RH_ID

        res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
        JSON.parse(res.body)
      end
    rescue
      {}
    end

    def self.fetch_account_number
      data["aws_account_id"]
    end

    def self.fetch_policy_json
      data.dig("aws_policies", "traditional_inspection")
    end
  end
end
