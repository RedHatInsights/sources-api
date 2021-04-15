module AvailabilityStatusConcern
  extend ActiveSupport::Concern

  included do
    before_update :reset_availability_callback
  end

  IGNORE_LIST = %w[
    availability_status
    availability_status_error
    last_available_at
    last_checked_at
    name
    superkey_data
    updated_at
    paused_at
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

  # sets availability status from caller's status
  # now Application -> Source
  #
  # @param caller [ActiveRecord::Base]
  def set_availability!(caller)
    self.availability_status = caller.availability_status
    if respond_to?(:availability_status_error) && caller.respond_to?(:availability_status_error)
      self.availability_status_error = caller.availability_status_error
    end
    self.last_checked_at = caller.last_checked_at
    save!
  end
end
