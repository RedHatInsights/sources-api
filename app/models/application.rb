class Application < ApplicationRecord
  include TenancyConcern
  belongs_to :source
  belongs_to :application_type

  has_many :application_authentications
  has_many :authentications, :through => :application_authentications

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true

  after_destroy :raise_event_message, :prepend => true

  private

  def raise_event_message
    headers = Insights::API::Common::Request.current_forwardable
    logger.debug("publishing message to topic \"platform.sources.event-stream\"...")
    Sources::Api::Events.raise_event("#{self.class}.destroy", self.as_json, headers)
    logger.debug("publishing message to topic \"platform.sources.event-stream\"...Complete")
  end
end
