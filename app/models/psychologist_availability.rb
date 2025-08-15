class PsychologistAvailability < ApplicationRecord
  belongs_to :psychologist_profile
  
  # Automatically convert time strings to Time objects.
  attribute :start_time_of_day, :time
  attribute :end_time_of_day, :time

  # Validations
  validates :start_time_of_day, presence: true
  validates :end_time_of_day, presence: true
  validates :day_of_week, presence: true, inclusion: 0..6
  validate :end_time_must_be_after_start_time

  private

  def end_time_must_be_after_start_time
    # Only validate if both times are present
    if start_time_of_day.present? && end_time_of_day.present?
      unless end_time_of_day > start_time_of_day
        errors.add(:end_time_of_day, "must be after the start time")
      end
    end
  end
end
