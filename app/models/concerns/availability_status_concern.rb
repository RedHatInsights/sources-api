module AvailabilityStatusConcern
  extend ActiveSupport::Concern

  included do
    before_update :update_status
  end

  private

  IGNORE_LIST = [
    "availability_status",
    "availability_status_error",
    "last_available_at",
    "last_checked_at",
    "updated_at",
    "name"
  ].freeze

  def update_status
    updated_attributes = changed - IGNORE_LIST

    if updated_attributes.any?
      self.availability_status = nil
      self.last_checked_at = nil

      if respond_to?(:availability_status_error)
        self.availability_status_error = nil
      end
    end
  end
end
