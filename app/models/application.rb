class Application < ApplicationRecord
  include TenancyConcern
  include EventConcern
  include AvailabilityStatusConcern

  belongs_to :source
  belongs_to :application_type

  has_many :application_authentications, :dependent => :destroy
  has_many :authentications, :through => :application_authentications

  attribute :availability_status, :string
  validates :availability_status, :inclusion => {:in => %w[available unavailable]}, :allow_nil => true

  validate :source_must_be_compatible

  before_save :copy_superkey_data
  after_create :superkey_workflow
  after_destroy :superkey_workflow, :reset_availability_on_source

  private

  def reset_availability_on_source
    return if source.endpoints.any?

    super
  end

  def source_must_be_compatible
    return if application_type.supported_source_types.include?(source.source_type.name)

    errors.add(:source, "of type: #{source.source_type.name}, is not compatible with this application type")
  end

  def superkey_workflow
    return unless source.super_key?

    if source.super_key_credential.nil?
      update!(
        :availability_status       => "unavailable",
        :availability_status_error => "The source is missing credentials for account authorization. Please remove the source and try to add it again / open a ticket to solve this issue."
      )
      return
    end

    sk = Sources::SuperKey.new(
      :provider    => source.source_type.name,
      :source_id   => source.id,
      :application => self
    )

    # the superkey_data hash tells whether or not the superkey workflow has been ran yet.
    if superkey_data.try(:[], "guid").nil?
      sk.create
    else
      sk.teardown
    end
  end

  def copy_superkey_data
    if extra.key?("_superkey")
      # pull out the superkey metadata we pass in from the worker
      self.superkey_data = extra.delete("_superkey")
    end
  end
end
