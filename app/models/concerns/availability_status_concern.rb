module AvailabilityStatusConcern
  extend ActiveSupport::Concern

  included do
    before_update :reset_availability_callback
  end

  private

  IGNORE_LIST = %w[
    "availability_status",
    "availability_status_error",
    "last_available_at",
    "last_checked_at",
    "updated_at",
    "name",
    "superkey_data"
  ].freeze

  # reset availability status only if allowed attributes were changed
  def reset_availability_callback
    updated_attributes = changed - IGNORE_LIST

    reset_availability if updated_attributes.any?
  end

  # parent method for model's reset_availability
  def reset_availability
    self.availability_status       = nil
    self.availability_status_error = nil if respond_to?(:availability_status_error)
    self.last_checked_at           = nil
  end

  def reset_availability!
    reset_availability
    save!
  end
end
