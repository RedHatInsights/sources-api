class Application < ApplicationRecord
  include TenancyConcern
  include EventConcern

  belongs_to :source
  belongs_to :application_type

  has_many :application_authentications, :dependent => :destroy
  has_many :authentications, :through => :application_authentications

  attribute :availability_status, :string
  validates :availability_status, :inclusion => { :in => %w[available unavailable] }, :allow_nil => true

  validate :source_must_be_compatible

  private

  def source_must_be_compatible
  	return if application_type.supported_source_types.include?(source.source_type.name)
  	errors.add(:source, "of type: #{source.source_type.name}, is not compatible with this application type")
  end
end
