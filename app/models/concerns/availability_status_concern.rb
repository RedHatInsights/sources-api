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
    "name",
    "superkey_data"
  ].freeze

  def update_status
    updated_attributes = changed - IGNORE_LIST

    remove_availability_status if updated_attributes.any?

    if self.class != Source && availability_status.nil?
      remove_availability_status_on_source
    end
  end

  def remove_availability_status
    self.availability_status = nil
    self.last_checked_at     = nil

    if respond_to?(:availability_status_error)
      self.availability_status_error = nil
    end
  end

  def remove_availability_status_on_source
    source.remove_availability_status!(self.class.name.to_sym)
  end
end
