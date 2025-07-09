# app/models/psychologist_availability.rb
class PsychologistAvailability < ApplicationRecord
  belongs_to :psychologist_profile

  validates :day_of_week, inclusion: { in: 0..6 }, uniqueness: { scope: :psychologist_profile_id, message: "can only have one default availability per day" }
  validates :timezone, presence: true

  # Removed presence validation for start_time_of_day and end_time_of_day
  validate :start_before_end, if: -> { start_time_of_day.present? && end_time_of_day.present? }

  # Accessors for the hour and minute parts from the form
  attr_accessor :start_time_of_day_hour, :start_time_of_day_minute,
                :end_time_of_day_hour, :end_time_of_day_minute

  # Callback to populate hour/minute accessors when an object is initialized (e.g., loaded from DB)
  after_initialize :set_time_parts_for_form, if: :persisted?

  # Callback to combine hour/minute into full time before validation/save
  before_validation :combine_time_parts

  def start_before_end
    errors.add(:end_time_of_day, "must be after start") if end_time_of_day <= start_time_of_day
  end

  def day_name
    # Ensure Monday = 0 is consistent with Date::DAYNAMES which starts with Sunday
    Date::DAYNAMES.rotate(1)[day_of_week]
  end

  private

  # Sets the hour and minute parts for the form's select fields
  def set_time_parts_for_form
    if start_time_of_day.present?
      self.start_time_of_day_hour = start_time_of_day.hour
      self.start_time_of_day_minute = start_time_of_day.min
    end
    if end_time_of_day.present?
      self.end_time_of_day_hour = end_time_of_day.hour
      self.end_time_of_day_minute = end_time_of_day.min
    end
  end

  # Combines the hour and minute parts into the actual time attributes
  def combine_time_parts
    # For start_time_of_day
    if start_time_of_day_hour.present? && start_time_of_day_minute.present?
      hour = start_time_of_day_hour.to_i
      minute = start_time_of_day_minute.to_i
      # Use Time.zone.parse for consistency with application's timezone
      self.start_time_of_day = Time.zone.parse("#{format('%02d', hour)}:#{format('%02d', minute)}")
    else
      self.start_time_of_day = nil # Set to nil if parts are missing
    end

    # For end_time_of_day
    if end_time_of_day_hour.present? && end_time_of_day_minute.present?
      hour = end_time_of_day_hour.to_i
      minute = end_time_of_day_minute.to_i
      self.end_time_of_day = Time.zone.parse("#{format('%02d', hour)}:#{format('%02d', minute)}")
    else
      self.end_time_of_day = nil # Set to nil if parts are missing
    end
  end
end
