class Source < ApplicationRecord
  SUPERKEY_WORKFLOW = "account_authorization".freeze

  include Pausable
  include TenancyConcern
  include EventConcern
  include AvailabilityStatusConcern
  attribute :uid, :string, :default => -> { SecureRandom.uuid }

  has_many :applications, :dependent => :destroy
  has_many :application_types, :through => :applications
  has_many :endpoints, :autosave => true, :dependent => :destroy
  has_many :authentications, :dependent => :destroy

  attribute :availability_status, :string
  validates :availability_status, :inclusion => {:in => %w[available partially_available unavailable in_progress]}, :allow_nil => true
  validates :app_creation_workflow, :inclusion => {:in => %w[manual_configuration account_authorization]}

  belongs_to :source_type

  delegate :scheme, :scheme=, :host, :host=, :port, :port=, :path, :path=,
           :to => :default_endpoint, :allow_nil => true
  validates :name, :presence => true, :allow_blank => false,
            :uniqueness => { :scope => :tenant_id }

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

  # reset from Application can't invoke new check in Application
  def reset_availability!(availability_check: true)
    reset_availability(:availability_check => availability_check)
  end

  # resets availability status and runs new availability check
  def reset_availability(availability_check: true)
    super()

    self.availability_check if availability_check
  end

  # requests availability check:
  # 1) through kafka (only for full(endpoint based) check)
  # 2) in connected applications
  def availability_check
    sources_availability_check if endpoints.any?

    applications.includes(:application_type)
                .each(&:availability_check)
  end

  private

  def sources_availability_check
    topic = Sources::Api::ClowderConfig.kafka_topic("platform.topological-inventory.operations-#{source_type.name}")

    logger.info("Initiating Source#availability_check [#{{"source_id" => id, "topic" => topic}}]")

    begin
      logger.debug("Publishing message for Source#availability_check [#{{"source_id" => id, "topic" => topic}}]")

      payload = {
        :params => {
          :source_id       => id.to_s,
          :source_uid      => uid.to_s,
          :source_ref      => source_ref.to_s,
          :external_tenant => tenant.external_tenant
        }
      }

      KafkaPublishJob.perform_later(topic, "Source.availability_check", payload)

      logger.debug("Publishing message for Source#availability_check [#{{"source_id" => id, "topic" => topic}}]...Complete")
    rescue => e
      logger.error("Hit error attempting to publish [#{{"source_id" => id, "topic" => topic}}] during Source#availability_check: #{e.message}")
    end
  end
end
