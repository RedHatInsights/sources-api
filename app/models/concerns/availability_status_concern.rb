module AvailabilityStatusConcern
  extend ActiveSupport::Concern

  included do
    before_update :update_status
  end

  def reset_availability
    self.availability_status = nil
    self.last_checked_at     = nil

    if respond_to?(:availability_status_error)
      self.availability_status_error = nil
    end
  end

  private

  IGNORE_LIST = [
    "availability_status",
    "availability_status_error",
    "last_available_at",
    "last_checked_at",
    "updated_at",
    "name",
    "superkey_data"
  ].freeze

  def update_status
    updated_attributes = changed - IGNORE_LIST

    reset_availability if updated_attributes.any?

    if self.class != Source && availability_status.nil?
      reset_availability_on_source
    end
  end

  def reset_availability_on_source
    source.reset_availability
  end
end
