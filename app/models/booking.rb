class Booking < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :service
  belongs_to :client_profile
  belongs_to :internal_client_profile


  validates :start_time, :end_time, :status, presence: true
  validate :at_least_one_client_present
  validate :start_before_end

  def at_least_one_client_present
    if client_profile.nil? && internal_client_profile.nil?
      errors.add(:base, "Either client_profile or internal_client_profile must be present")
    end
  end

  def start_before_end
    if start_time && end_time && end_time <= start_time
      errors.add(:end_time, "must be after start_time")
    end
  end
end
