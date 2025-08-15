# class PsychologistAvailability < ApplicationRecord
#   belongs_to :psychologist_profile
#   before_validation :set_local_times_from_form

#   validates :day_of_week, inclusion: { in: 0..6 }
#   validates :timezone, presence: true
#   validate :valid_time_range

#   attr_accessor :start_time, :end_time

#   def day_name
#     Date::DAYNAMES[day_of_week]
#   end

#   def start_time_in_zone(viewer_timezone = nil)
#     viewer_timezone ||= Thread.current[:viewer_timezone] || 'UTC'
#     return unless start_time_of_day

#     psych_tz = ActiveSupport::TimeZone[timezone]
#     viewer_tz = ActiveSupport::TimeZone[viewer_timezone]
#     today_in_psych = Date.current.in_time_zone(psych_tz).to_date

#     dt_in_psych = psych_tz.local(today_in_psych.year, today_in_psych.month, today_in_psych.day,
#                                 start_time_of_day.hour, start_time_of_day.min)
#     dt_in_psych.in_time_zone(viewer_tz)
#   end

#   def end_time_in_zone(viewer_timezone = nil)
#     viewer_timezone ||= Thread.current[:viewer_timezone] || 'UTC'
#     return unless end_time_of_day

#     psych_tz = ActiveSupport::TimeZone[timezone]
#     viewer_tz = ActiveSupport::TimeZone[viewer_timezone]
#     today_in_psych = Date.current.in_time_zone(psych_tz).to_date

#     dt_in_psych = psych_tz.local(today_in_psych.year, today_in_psych.month, today_in_psych.day,
#                                 end_time_of_day.hour, end_time_of_day.min)
#     dt_in_psych.in_time_zone(viewer_tz)
#   end


#   private

#   def valid_time_range
#     return if start_time_of_day.blank? || end_time_of_day.blank?

#     if start_time_of_day == end_time_of_day
#       errors.add(:end_time_of_day, "must be different from start time")
#     elsif end_time_of_day < start_time_of_day
#       errors.add(:end_time_of_day, "must be after start time")
#     end
#   end

#   def set_local_times_from_form
#     if start_time.present? && end_time.present?
#       begin
#         self.start_time_of_day = Time.parse(start_time)
#         self.end_time_of_day   = Time.parse(end_time)
#       rescue ArgumentError
#         errors.add(:base, "Invalid time format submitted.")
#         throw :abort
#       end
#     else
#       self.start_time_of_day = nil
#       self.end_time_of_day   = nil
#     end
#   end
# end
# app/models/psychologist_availability.rb

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
