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

  # def start_time_in_zone(timezone = nil)
  #   timezone ||= self.timezone || 'UTC'
  #   # FIX: Combine the time with a consistent date to avoid DST conversion issues.
  #   # This ensures the time is always displayed correctly.
  #   base_date = ActiveSupport::TimeZone[timezone].now
  #   base_date.change(hour: start_time_of_day.hour, min: start_time_of_day.min, sec: start_time_of_day.sec)
  # end 

  # def end_time_in_zone(timezone = nil)
  #   timezone ||= self.timezone || 'UTC'
  #   # FIX: Combine the time with a consistent date to avoid DST conversion issues.
  #   # This ensures the time is always displayed correctly.
  #   base_date = ActiveSupport::TimeZone[timezone].now
  #   base_date.change(hour: end_time_of_day.hour, min: end_time_of_day.min, sec: end_time_of_day.sec)
  # end
  def start_time_in_zone(timezone = nil)
    timezone ||= self.timezone || 'UTC'
    if self.start_time_of_day.present?
      # FIX: Use Time.zone.now to get a date with the correct DST offset.
      Time.use_zone(timezone) do
        today_in_zone = Time.zone.now
        Time.zone.local(today_in_zone.year, today_in_zone.month, today_in_zone.day, self.start_time_of_day.hour, self.start_time_of_day.min)
      end
    end
  end

  def end_time_in_zone(timezone = nil)
    timezone ||= self.timezone || 'UTC'
    if self.end_time_of_day.present?
      # FIX: Use Time.zone.now to get a date with the correct DST offset.
      Time.use_zone(timezone) do
        today_in_zone = Time.zone.now
        Time.zone.local(today_in_zone.year, today_in_zone.month, today_in_zone.day, self.end_time_of_day.hour, self.end_time_of_day.min)
      end
    end
  end

  private

  def set_utc_times_from_form
    if start_time.present? && end_time.present?
      # FIX: Use the current time in the specified timezone as a base.
      # This correctly handles Daylight Saving Time (DST) by using the appropriate
      # offset for the current date, whether it's summer or winter.
      # The previous hardcoded date in winter was causing the one-hour shift
      # when a user on a DST timezone saved their availability.
      base_date = ActiveSupport::TimeZone[timezone].now

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