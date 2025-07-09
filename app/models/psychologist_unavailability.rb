# app/models/psychologist_unavailability.rb
class PsychologistUnavailability < ApplicationRecord
  belongs_to :psychologist_profile

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :reason, presence: true, length: { maximum: 255 }
  validates :timezone, presence: true

  validate :end_time_after_start_time
  validate :day_of_week_for_recurring, if: :recurring?

  # Ensures end_time is after start_time
  def end_time_after_start_time
    if start_time.present? && end_time.present? && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  # Validates day_of_week for recurring unavailabilities
  def day_of_week_for_recurring
    if recurring && day_of_week.blank?
      errors.add(:day_of_week, "must be specified for recurring unavailability")
    end
  end

  # Helper to convert day_of_week integer to day name (0=Sunday, 1=Monday...)
  def day_name
    Date::DAYNAMES[day_of_week] if day_of_week.present?
  end

  # Scope to get non-recurring events or recurring events within a range
  def self.for_calendar(start_date, end_date)
    where(
      "(recurring = ? AND (start_time BETWEEN ? AND ? OR end_time BETWEEN ? AND ?)) OR " +
      "(recurring = ? AND (recurring_until IS NULL OR recurring_until >= ?))",
      false, start_date, end_date, start_date, end_date,
      true, start_date
    )
  end
end
