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
  after_create :create_superkey_workflow
  after_destroy :teardown_superkey_workflow

  def remove_availability_status!
    remove_availability_status
    save!
  end

  def remove_availability_status
    self.availability_status       = nil
    self.last_checked_at           = nil
    self.availability_status_error = nil
  end

  private

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
end
