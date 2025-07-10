# app/models/psychologist_unavailability.rb
class PsychologistUnavailability < ApplicationRecord
  belongs_to :psychologist_profile

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :reason, presence: true, length: { maximum: 255 }
  validates :timezone, presence: true

  # This validation is now generally applied and more specific ones handle recurring/one-off nuances
  validate :end_time_after_start_time_generic # Renamed for clarity to avoid confusion with recurring specific one

  # No longer need this line, as the actual day_of_week validation is below
  # validate :day_of_week_for_recurring, if: :recurring? # <-- REMOVE THIS LINE

  # Conditional validations for one-off unavailabilities
  with_options unless: :recurring? do
    # These are already covered by the generic presence: true, but good for explicit clarity if needed
    # validates :start_time, presence: true
    # validates :end_time, presence: true
    # The generic end_time_after_start_time_generic will cover this for one-off
    validates :day_of_week, absence: { message: "should not be set for one-off unavailability" }
    validates :recurring_until, absence: { message: "should not be set for one-off unavailability" }
  end

  # Conditional validations for recurring unavailabilities
  with_options if: :recurring? do
    validates :day_of_week, presence: true, inclusion: { in: 0..6 } # 0 for Sunday, 6 for Saturday
    validates :recurring_until, presence: true, on: :create # on: :create to ensure it's set initially
    # For recurring, start_time and end_time only provide the time component
    # Presence is already covered by the generic, but useful for context here
    # validates :start_time, presence: true
    # validates :end_time, presence: true
    validate :recurring_end_time_after_start_time
    validate :recurring_until_in_future # Optional: if you don't want to create past recurring
  end

  # Helper to get the day name from the integer
  def day_name
    Date::DAYNAMES[day_of_week] if day_of_week.present?
  end

  # Scope to get non-recurring events or recurring events within a range for calendar display
  def self.for_calendar(start_date, end_date)
    # The start_date in this context refers to the calendar's view start.
    # We want recurring rules that are still active (not expired before the start_date of the view)
    # or one-off events that fall within the view.
    where(
      "(recurring = ? AND start_time <= ? AND end_time >= ?) OR " + # One-off events that overlap the range
      "(recurring = ? AND (recurring_until IS NULL OR recurring_until >= ?))", # Recurring rules that are still active
      false, end_date, start_date, # Parameters for one-off condition
      true, start_date # Parameters for recurring condition
    )
  end


  private

  # Generic validation for end_time after start_time, applicable to one-off
  def end_time_after_start_time_generic
    # This applies if both are present. For recurring, `recurring_end_time_after_start_time` is used.
    # This also acts as a fallback for recurring if the specific validation fails to run due to other errors.
    if !recurring? && start_time.present? && end_time.present? && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  # Specific validation for recurring events to only compare time components
  def recurring_end_time_after_start_time
    return unless start_time && end_time
    # Use strftime to compare only the time component
    if end_time.strftime('%H:%M') <= start_time.strftime('%H:%M')
      errors.add(:end_time, "time must be after start time for recurring unavailability")
    end
  end

  def recurring_until_in_future
    return unless recurring_until.present? # Check for presence before comparing
    # We need to consider the current date in the user's timezone if possible,
    # but Date.current (Rails' default) uses the application's default timezone, which is usually fine for dates.
    if recurring_until < Date.current
      errors.add(:recurring_until, "date cannot be in the past")
    end
  end
end