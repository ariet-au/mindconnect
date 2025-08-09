# class PsychologistAvailability < ApplicationRecord
#   belongs_to :psychologist_profile

#   # Validations
#   validates :day_of_week, inclusion: { in: 0..6 }
#   validates :timezone, presence: true

#   # Virtual attributes for form inputs (HH:MM in local timezone)
#   attr_accessor :start_time, :end_time

#   # Convert local time inputs to UTC before saving
#   before_validation :set_utc_times_from_form

#   # Helper method to get the day name
#   def day_name
#     Date::DAYNAMES[day_of_week]
#   end
#   def start_time_in_zone(timezone = nil)
#     timezone ||= self.timezone || 'UTC'
#     if self.start_time_of_day.present?
#       # FIX: Use Time.zone.now to get a date with the correct DST offset.
#       Time.use_zone(timezone) do
#         today_in_zone = Time.zone.now
#         Time.zone.local(today_in_zone.year, today_in_zone.month, today_in_zone.day, self.start_time_of_day.hour, self.start_time_of_day.min)
#       end
#     end
#   end

#   def end_time_in_zone(timezone = nil)
#     timezone ||= self.timezone || 'UTC'
#     if self.end_time_of_day.present?
#       # FIX: Use Time.zone.now to get a date with the correct DST offset.
#       Time.use_zone(timezone) do
#         today_in_zone = Time.zone.now
#         Time.zone.local(today_in_zone.year, today_in_zone.month, today_in_zone.day, self.end_time_of_day.hour, self.end_time_of_day.min)
#       end
#     end
#   end

#   private


#   def set_utc_times_from_form
#     if start_time.present? && end_time.present?
#       tz = ActiveSupport::TimeZone[timezone] || Time.zone
#       reference_date = Date.current

#       start_hour, start_minute = start_time.split(':').map(&:to_i)
#       end_hour, end_minute     = end_time.split(':').map(&:to_i)

#       # Build in psychologist's local zone
#       local_start = tz.local(reference_date.year, reference_date.month, reference_date.day, start_hour, start_minute)
#       local_end   = tz.local(reference_date.year, reference_date.month, reference_date.day, end_hour, end_minute)

#       # Convert to real UTC before saving
#       self.start_time_of_day = local_start.in_time_zone('UTC')
#       self.end_time_of_day   = local_end.in_time_zone('UTC')
#     else
#       self.start_time_of_day = nil
#       self.end_time_of_day = nil
#     end
#   end
# end

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
      # Use a more reliable approach to convert the UTC time to the specified zone
      self.start_time_of_day.in_time_zone(timezone)
    end
  end

  def end_time_in_zone(timezone = nil)
    timezone ||= self.timezone || 'UTC'
    if self.end_time_of_day.present?
      # Use a more reliable approach to convert the UTC time to the specified zone
      self.end_time_of_day.in_time_zone(timezone)
    end
  end

  private

  def set_utc_times_from_form
    # FIX: Use Time.parse to handle multiple time string formats and add error handling.
    if start_time.present? && end_time.present?
      begin
        tz = ActiveSupport::TimeZone[timezone] || Time.zone

        # Use Time.parse, which is more flexible than split(':'),
        # to correctly interpret the time string from the form.
        local_start = Time.parse(start_time).in_time_zone(tz)
        local_end   = Time.parse(end_time).in_time_zone(tz)

        # Convert to real UTC before saving
        self.start_time_of_day = local_start.utc
        self.end_time_of_day   = local_end.utc
      rescue ArgumentError => e
        # Catch any parsing errors and add a user-friendly error message.
        errors.add(:base, "Invalid time format submitted.")
        throw :abort
      end
    else
      # If either field is not present, set the database fields to nil.
      self.start_time_of_day = nil
      self.end_time_of_day = nil
    end
  end
end
