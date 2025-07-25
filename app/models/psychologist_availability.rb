# app/models/psychologist_availability.rb

class PsychologistAvailability < ApplicationRecord
  belongs_to :psychologist_profile

  validates :day_of_week, inclusion: { in: 0..6 }, uniqueness: { scope: :psychologist_profile_id, message: "can only have one default availability per day" }
  validates :timezone, presence: true
  validate :start_before_end, if: -> { start_time_of_day.present? && end_time_of_day.present? }

  # Virtual attributes to capture form input for hours and minutes
  attr_accessor :start_time_of_day_hour, :start_time_of_day_minute,
                :end_time_of_day_hour, :end_time_of_day_minute

  # === CALLBACKS FOR TIMEZONE CONVERSION ===
  # When loading from DB (UTC -> Local), set virtual attributes for the form
  after_initialize :set_local_time_parts_for_form, if: -> { persisted? && timezone.present? }
  # Before saving (Local -> UTC), combine virtual attributes into time fields
  before_validation :set_utc_times_from_form_parts

  def start_before_end
    # This comparison works correctly because both are time objects
    errors.add(:end_time_of_day, "must be after start time") if end_time_of_day <= start_time_of_day
  end

  def day_name
    # Monday = 0, Sunday = 6. Rotates Date::DAYNAMES which starts with Sunday.
    Date::DAYNAMES[day_of_week]
  end


  

  private

  # CONVERT FROM UTC (DATABASE) TO PSYCHOLOGIST'S LOCAL TIME (FORM)
  def set_local_time_parts_for_form
    # Set Start Time Parts
    if start_time_of_day.present?
      local_start_time = start_time_of_day.in_time_zone(self.timezone)
      self.start_time_of_day_hour ||= local_start_time.hour
      self.start_time_of_day_minute ||= local_start_time.min
    end

    # Set End Time Parts
    if end_time_of_day.present?
      local_end_time = end_time_of_day.in_time_zone(self.timezone)
      self.end_time_of_day_hour ||= local_end_time.hour
      self.end_time_of_day_minute ||= local_end_time.min
    end
  end

  def handle_nil_times
    if start_time_of_day_hour.blank? || start_time_of_day_minute.blank? ||
       end_time_of_day_hour.blank?   || end_time_of_day_minute.blank?
      self.start_time_of_day = nil
      self.end_time_of_day = nil
    else
      self.start_time_of_day = Time.zone.parse("#{start_time_of_day_hour}:#{start_time_of_day_minute}")
      self.end_time_of_day   = Time.zone.parse("#{end_time_of_day_hour}:#{end_time_of_day_minute}")
    end
  end

  # CONVERT FROM PSYCHOLOGIST'S LOCAL TIME (FORM) TO UTC (DATABASE)
  def set_utc_times_from_form_parts
    # Use the psychologist's specific timezone to correctly interpret the time parts
    Time.use_zone(self.timezone) do
      # Process Start Time
      if start_time_of_day_hour.present? && start_time_of_day_minute.present?
        hour = start_time_of_day_hour.to_i
        minute = start_time_of_day_minute.to_i
        # Time.zone.parse creates a time in the psychologist's local zone.
        # Rails automatically saves its UTC equivalent to the database.
        self.start_time_of_day = Time.zone.parse("#{format('%02d', hour)}:#{format('%02d', minute)}")
      elsif start_time_of_day_hour.blank? && start_time_of_day_minute.blank?
        self.start_time_of_day = nil # User cleared the time
      end

      # Process End Time
      if end_time_of_day_hour.present? && end_time_of_day_minute.present?
        hour = end_time_of_day_hour.to_i
        minute = end_time_of_day_minute.to_i
        self.end_time_of_day = Time.zone.parse("#{format('%02d', hour)}:#{format('%02d', minute)}")
      elsif end_time_of_day_hour.blank? && end_time_of_day_minute.blank?
        self.end_time_of_day = nil # User cleared the time
      end
    end
  end
end