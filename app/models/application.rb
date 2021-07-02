class Application < ApplicationRecord
  include Pausable
  include TenancyConcern
  include EventConcern
  include AvailabilityStatusConcern

  belongs_to :source
  belongs_to :application_type

  has_many :application_authentications, :dependent => :destroy
  has_many :authentications, :through => :application_authentications

  attribute :availability_status, :string
  validates :availability_status, :inclusion => {:in => %w[available unavailable in_progress]}, :allow_nil => true

  validate :source_must_be_compatible

  before_save :copy_superkey_data
  after_create :create_superkey_workflow
  after_destroy :teardown_superkey_workflow
  after_discard :discard_workflow
  after_undiscard :undiscard_workflow

  after_update :set_availability

  # Calls external service to do availability check
  # Source's status is updated by the external update
  def reset_availability
    super

    source.reset_availability!(:availability_check => false) if source.endpoints.blank?

    availability_check
  end

  def set_availability
    if saved_change_to_attribute?(:availability_status) && availability_status.present?
      # If Source has an endpoint, apps' statuses don't influence the source's status
      return if source.endpoints.any?

      # TODO: partially_available status (later) couldn't overwrite
      source.set_availability!(self)
    end
  end

  # Calls availability check on connected service
  # TODO: should be processed by resque/sidekiq(/kafka?)
  def availability_check
    return if (url = availability_check_url).nil?

    logger.info("Requesting #{application_type.display_name} Application#availability_check [#{{"source_id" => source.id, "url" => url}}]")

    uri                   = URI.parse(url)
    net_http              = Net::HTTP.new(uri.host, uri.port)
    net_http.open_timeout = net_http.read_timeout = 10

    request      = Net::HTTP::Post.new(uri.request_uri, availability_check_headers)
    request.body = {"source_id" => source.id.to_s}.to_json

    response = net_http.request(request)
    raise response.message unless response.kind_of?(Net::HTTPSuccess)
  rescue => e
    logger.error("Failed to request #{application_type.display_name} Application#availability_check [#{{"source_id" => source.id, "url" => url}}] Error: #{e.message}")
  end

  private

  def availability_check_url
    app_env_prefix = application_type.name.split('/').last.upcase.tr('-', '_')
    url            = ENV["#{app_env_prefix}_AVAILABILITY_CHECK_URL"]

    # ENVs consist of 3 parameters separated by '://' or ':'
    return nil if url.to_s.gsub(/[:\/]/, '').strip.blank?

    url
  end

  def availability_check_headers
    {
      "Content-Type"  => "application/json",
      "x-rh-identity" => Base64.strict_encode64({'identity' => {'account_number' => source.tenant.external_tenant}}.to_json)
    }
  end

  def source_must_be_compatible
    return if application_type.supported_source_types.include?(source.source_type.name)

    errors.add(:source, "of type: #{source.source_type.name}, is not compatible with this application type")
  end

  def create_superkey_workflow
    return unless source.super_key?

    if source.super_key_credential.nil?
      # update the availability status on the application if the application was created
      # on a superkey source and there is _NO_ superkey credential
      update!(
        :availability_status       => "unavailable",
        :availability_status_error => "The source is missing credentials for account authorization. Please remove the source and try to add it again / open a ticket to solve this issue."
      )

      # can't really do much if we don't have a superkey credential.
      return
    end

    sk = Sources::SuperKey.new(
      :provider    => source.source_type.name,
      :source_id   => source.id,
      :application => self
    )

    sk.create
  end

  def teardown_superkey_workflow
    return unless source.super_key? && source.super_key_credential
    return if Redis.current.get("application_#{id}_delete_queued")

    sk = Sources::SuperKey.new(
      :provider    => source.source_type.name,
      :source_id   => source.id,
      :application => self
    )
    sk.teardown
  end

  def copy_superkey_data
    if extra.key?("_superkey")
      # pull out the superkey metadata we pass in from the worker
      self.superkey_data = extra.delete("_superkey")
    end
  end

  # pause all applications and pause source if all applications
  # have been paused
  def discard_workflow
    authentications.discard_all
    application_authentications.discard_all
    if Application.where(:source_id => source_id).all?(&:discarded?)
      source.discard
      source.endpoints.discard_all
    end
  end

  # inverse of above.
  def undiscard_workflow
    authentications.undiscard_all
    application_authentications.undiscard_all
    source.undiscard
    source.endpoints.undiscard_all
  end
end
