class Booking < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :service , optional: true
  belongs_to :client_profile, optional: true
  belongs_to :internal_client_profile, optional: true


  validates :start_time, :end_time, :status, presence: true
  validate :at_least_one_client_present

  before_validation :set_end_time, if: :start_time_changed?

  validate :end_time_after_start_time

    VALID_STATUSES = ['pending', 'confirmed', 'cancelled', 'completed'].freeze
  validates :status, inclusion: { in: VALID_STATUSES }

  def at_least_one_client_present
    if client_profile.nil? && internal_client_profile.nil?
      errors.add(:base, "Either client_profile or internal_client_profile must be present")
    end
  end

  private

  def set_end_time
    if service.present? && start_time.present?
      self.end_time = start_time + service.duration_minutes.minutes
    else
      self.end_time = nil # Or handle appropriately if not present
    end
  end

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end


  def set_default_status
    self.status ||= 'pending' if self.status.blank?
  end
end

