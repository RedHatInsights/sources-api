class Source < ApplicationRecord
  SUPERKEY_WORKFLOW = "account_authorization".freeze

  include TenancyConcern
  include EventConcern
  include AvailabilityStatusConcern
  attribute :uid, :string, :default => -> { SecureRandom.uuid }

  has_many :applications, :dependent => :destroy
  has_many :application_types, :through => :applications
  has_many :endpoints, :autosave => true, :dependent => :destroy
  has_many :authentications, :dependent => :destroy

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available partially_available unavailable] }, :allow_nil => true
  validates :app_creation_workflow, :inclusion => {:in => %w[manual_configuration account_authorization]}

  belongs_to :source_type

  delegate :scheme, :scheme=, :host, :host=, :port, :port=, :path, :path=,
           :to => :default_endpoint, :allow_nil => true
  validates :name, :presence => true, :allow_blank => false,
            :uniqueness => { :scope => :tenant_id }

  after_update :availability_check, :unless => :availability_status

  def default_endpoint
    default = endpoints.detect(&:default)
    default || endpoints.build(:default => true, :tenant => tenant)
  end

  def super_key?
    app_creation_workflow == SUPERKEY_WORKFLOW
  end

  # finds the superkey authentication tied to the Source
  def super_key_credential
    authentications.detect { |a| a.authtype == source_type.superkey_authtype }
  end

  def remove_availability_status(source = nil)
    return if source == :Application && endpoints.any?

    self.availability_status = nil
    self.last_checked_at = nil
  end

  def remove_availability_status!(source = nil)
    return if availability_status.nil?

    remove_availability_status(source)
    save!
  end

  def availability_check
    check_source_availability
    check_application_availability
  end

  private

  def check_source_availability
    topic = "platform.topological-inventory.operations-#{source_type.name}"

    logger.info("Initiating Source#availability_check [#{{"source_id" => id, "topic" => topic}}]")

    begin
      logger.debug("Publishing message for Source#availability_check [#{{"source_id" => id, "topic" => topic}}]")

      Sources::Api::Messaging.client.publish_topic(
        :service => topic,
        :event   => "Source.availability_check",
        :payload => {
          :params => {
            :source_id       => id.to_s,
            :source_uid      => uid.to_s,
            :source_ref      => source_ref.to_s,
            :external_tenant => tenant.external_tenant
          }
        }
      )

      logger.debug("Publishing message for Source#availability_check [#{{"source_id" => id, "topic" => topic}}]...Complete")
    rescue => e
      logger.error("Hit error attempting to publish [#{{"source_id" => id, "topic" => topic}}] during Source#availability_check: #{e.message}")
    end
  end

  def check_application_availability
    application_types.each do |app_type|
      app_env_prefix = app_type.name.split('/').last.upcase.tr('-', '_')
      url = ENV["#{app_env_prefix}_AVAILABILITY_CHECK_URL"]
      next if url.blank?

      logger.info("Requesting #{app_type.display_name} Source#availability_check [#{{"source_id" => id, "url" => url}}]")

      begin
        headers = {
          "Content-Type"  => "application/json",
          "x-rh-identity" => Base64.strict_encode64({'identity' => {'account_number' => tenant.external_tenant}}.to_json)
        }

        uri = URI.parse(url)
        net_http = Net::HTTP.new(uri.host, uri.port)
        net_http.open_timeout = net_http.read_timeout = 10

        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.body = {"source_id" => id.to_s}.to_json

        response = net_http.request(request)
        raise response.message unless response.kind_of?(Net::HTTPSuccess)
      rescue => e
        logger.error("Failed to request #{app_type.display_name} Source#availability_check [#{{"source_id" => id, "url" => url}}] Error: #{e.message}")
      end
    end
  end
end
