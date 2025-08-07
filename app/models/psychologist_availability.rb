class PsychologistAvailability < ApplicationRecord
  belongs_to :psychologist_profile

  # Validations
  validates :day_of_week, inclusion: { in: 0..6 }
  validates :timezone, presence: true

  # Virtual attributes for form inputs (HH:MM in local timezone)
  attr_accessor :start_time, :end_time

  # Convert local time inputs to UTC before saving
  before_validation :set_utc_times_from_form

  # Helper method to get the day name
  def day_name
    Date::DAYNAMES[day_of_week]
  end

  def start_time_in_zone(timezone = nil)
    timezone ||= self.timezone || 'UTC'
    start_time_of_day.in_time_zone(timezone)
  end

  def end_time_in_zone(timezone = nil)
    timezone ||= self.timezone || 'UTC'
    end_time_of_day.in_time_zone(timezone)
  end

  private

  def set_utc_times_from_form
    if start_time.present? && end_time.present?
      # Use a fixed, non-DST date to create a reference time in the local timezone.
      # This ensures the UTC offset is consistent and not affected by the current date.
      
      # For a timezone that observes DST, using a date in the middle of winter
      # (e.g., January 1st) is a safe bet for a non-DST offset.
      base_date = Date.new(2000, 1, 1).in_time_zone(timezone)
      
      # Parse start time
      hour, minute = start_time.split(':').map(&:to_i)
      self.start_time_of_day = base_date.change(hour: hour, min: minute).utc

      # Parse end time
      hour, minute = end_time.split(':').map(&:to_i)
      self.end_time_of_day = base_date.change(hour: hour, min: minute).utc
    else
      self.start_time_of_day = nil
      self.end_time_of_day = nil
    end
  end
end