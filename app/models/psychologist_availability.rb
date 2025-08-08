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

  # def set_utc_times_from_form
  #   if start_time.present? && end_time.present?
  #     base_date = ActiveSupport::TimeZone[timezone].now

  #     # Parse start time
  #     hour, minute = start_time.split(':').map(&:to_i)
  #     self.start_time_of_day = base_date.change(hour: hour, min: minute).utc

  #     # Parse end time
  #     hour, minute = end_time.split(':').map(&:to_i)
  #     self.end_time_of_day = base_date.change(hour: hour, min: minute).utc
  #   else
  #     self.start_time_of_day = nil
  #     self.end_time_of_day = nil
  #   end
  # end
  def set_utc_times_from_form
    if start_time.present? && end_time.present?
      tz = ActiveSupport::TimeZone[timezone] || Time.zone
      reference_date = Date.current

      start_hour, start_minute = start_time.split(':').map(&:to_i)
      end_hour, end_minute     = end_time.split(':').map(&:to_i)

      # Build in psychologist's local zone
      local_start = tz.local(reference_date.year, reference_date.month, reference_date.day, start_hour, start_minute)
      local_end   = tz.local(reference_date.year, reference_date.month, reference_date.day, end_hour, end_minute)

      # Convert to real UTC before saving
      self.start_time_of_day = local_start.in_time_zone('UTC')
      self.end_time_of_day   = local_end.in_time_zone('UTC')
    else
      self.start_time_of_day = nil
      self.end_time_of_day = nil
    end
  end
end