# app/models/psychologist_unavailability.rb
class PsychologistUnavailability < ApplicationRecord
  belongs_to :psychologist_profile

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :reason, presence: true, length: { maximum: 255 }
  validates :timezone, presence: true

  validate :end_time_after_start_time_generic 
  with_options unless: :recurring? do
    validates :day_of_week, absence: { message: "should not be set for one-off unavailability" }
    validates :recurring_until, absence: { message: "should not be set for one-off unavailability" }
  end

  with_options if: :recurring? do
    validates :day_of_week, presence: true, inclusion: { in: 0..6 }
    validates :recurring_until, presence: true, on: :create
    validate :recurring_end_time_after_start_time
    validate :recurring_until_in_future
  end

  def day_name
    Date::DAYNAMES[day_of_week] if day_of_week.present?
  end

  def self.for_calendar(start_date, end_date)
    where(
      "(recurring = ? AND start_time <= ? AND end_time >= ?) OR " +
      "(recurring = ? AND (recurring_until IS NULL OR recurring_until >= ?))",
      false, end_date, start_date,
      true, start_date 
    )
  end

  # Convert stored UTC times to psychologist's timezone for display
  def local_start_time
    start_time.in_time_zone(timezone)
  end

  def local_end_time
    end_time.in_time_zone(timezone)
  end

  private

  def end_time_after_start_time_generic
    if !recurring? && start_time.present? && end_time.present? && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def recurring_end_time_after_start_time
    return unless start_time && end_time
    if end_time.strftime('%H:%M') <= start_time.strftime('%H:%M')
      errors.add(:end_time, "time must be after start time for recurring unavailability")
    end
  end

  def recurring_until_in_future
    return unless recurring_until.present?
    if recurring_until < Date.current
      errors.add(:recurring_until, "date cannot be in the past")
    end
  end
end