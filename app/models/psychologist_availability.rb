class PsychologistAvailability < ApplicationRecord
  belongs_to :psychologist_profile

  # Validations
  validates :day_of_week, inclusion: { in: 0..6 }
  validates :timezone, presence: true
  validate :times_both_present_or_both_blank
  validate :start_before_end, if: -> { start_time_of_day.present? && end_time_of_day.present? }

  # Virtual attributes for form inputs (HH:MM in local timezone)
  attr_accessor :start_time, :end_time

  # Convert local time inputs to UTC before saving
  before_validation :set_utc_times_from_form

  # Helper method to get the day name
  def day_name
    Date::DAYNAMES[day_of_week]
  end

  private

  def set_utc_times_from_form
    if start_time.present? && end_time.present?
      # Parse start time in psychologist's timezone
      hour, minute = start_time.split(':').map(&:to_i)
      date = DateTime.now.in_time_zone(timezone)
      self.start_time_of_day = date.change(hour: hour, min: minute).utc

      # Parse end time in psychologist's timezone
      hour, minute = end_time.split(':').map(&:to_i)
      date = DateTime.now.in_time_zone(timezone)
      self.end_time_of_day = date.change(hour: hour, min: minute).utc
    else
      self.start_time_of_day = nil
      self.end_time_of_day = nil
    end
  end

  def times_both_present_or_both_blank
    if start_time.present? && end_time.blank?
      errors.add(:end_time, "must be provided if start time is set")
    elsif end_time.present? && start_time.blank?
      errors.add(:start_time, "must be provided if end time is set")
    end
  end

  def start_before_end
    if end_time_of_day <= start_time_of_day
      errors.add(:end_time_of_day, "must be after start time")
    end
  end
end