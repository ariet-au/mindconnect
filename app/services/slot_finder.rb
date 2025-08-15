# app/services/slot_finder.rb
class SlotFinder
  SLOT_INTERVAL = 15.minutes # 15-minute intervals: 00, 15, 30, 45

  def initialize(psychologist_profile_id, duration_minutes, user_timezone = 'UTC')
    @psychologist = PsychologistProfile.find(psychologist_profile_id)
    @duration = duration_minutes.minutes
    @user_timezone = user_timezone.presence || 'UTC'
    @psychologist_timezone_name = @psychologist.timezone.presence || 'UTC'
    @psych_tz = ActiveSupport::TimeZone[@psychologist_timezone_name] || ActiveSupport::TimeZone['UTC']
  end

  def all_available_slots_by_day(from_time = Time.current, days_to_search = 14)
    available_slots_by_day = {}
    search_start_time = from_time.in_time_zone(@psych_tz) rescue Time.current.in_time_zone(@psych_tz)

    (0...days_to_search).each do |day_offset|
      target_date = (search_start_time.to_date + day_offset.days)
      day_of_week = target_date.wday

      @psychologist.psychologist_availabilities.where(day_of_week: day_of_week).order(:start_time_of_day).each do |availability|
        availability_start_utc = combine_date_and_time_to_utc(target_date, availability.start_time_of_day)
        availability_end_utc = combine_date_and_time_to_utc(target_date, availability.end_time_of_day)

        next unless availability_start_utc && availability_end_utc

        slots_in_period_utc = find_all_slots_in_period(availability_start_utc, availability_end_utc, search_start_time.utc)

        slots_in_period_utc.each do |slot_utc|
          slot_in_user_tz = slot_utc.in_time_zone(@user_timezone)
          date_key = slot_in_user_tz.to_date
          (available_slots_by_day[date_key] ||= []) << slot_in_user_tz
        end
      end
    end

    available_slots_by_day
  end

  def next_available_slot(from_time = Time.current)
    from_time_in_psych_tz = from_time.in_time_zone(@psych_tz) rescue Time.current.in_time_zone(@psych_tz)
    
    # Round to next 15-minute interval
    rounded_min = (from_time_in_psych_tz.min / 15.0).ceil * 15

    if rounded_min >= 60
      initial_check_time_psych_tz = from_time_in_psych_tz.change(min: 0, sec: 0) + 1.hour
    else
      initial_check_time_psych_tz = from_time_in_psych_tz.change(min: rounded_min, sec: 0)
    end

    (0..13).each do |day_offset|
      target_date_in_psych_tz = (initial_check_time_psych_tz + day_offset.days).to_date
      day_of_week = target_date_in_psych_tz.wday

      @psychologist.psychologist_availabilities.where(day_of_week: day_of_week).order(:start_time_of_day).each do |availability|
        availability_period_start_utc = combine_date_and_time_to_utc(target_date_in_psych_tz, availability.start_time_of_day)
        availability_period_end_utc = combine_date_and_time_to_utc(target_date_in_psych_tz, availability.end_time_of_day)
        next unless availability_period_start_utc && availability_period_end_utc

        slot_search_start_utc = [availability_period_start_utc, initial_check_time_psych_tz.utc].max
        next if slot_search_start_utc >= availability_period_end_utc

        if found_slot_utc = find_first_valid_slot_in_period(slot_search_start_utc, availability_period_end_utc)
          return found_slot_utc.in_time_zone(@user_timezone)
        end
      end
    end
    nil
  end

  private

  def find_all_slots_in_period(period_start_utc, period_end_utc, search_start_utc)
    found_slots = []
    slot_start_utc = [period_start_utc, search_start_utc].max.beginning_of_minute

    # Round to next 15-minute interval
    if slot_start_utc.min % 15 != 0
      rounded_min = (slot_start_utc.min / 15.0).ceil * 15
      if rounded_min >= 60
        slot_start_utc = (slot_start_utc + 1.hour).beginning_of_hour
      else
        slot_start_utc = slot_start_utc.change(min: rounded_min)
      end
    end

    # Generate slots at 15-minute intervals
    while slot_start_utc + @duration <= period_end_utc
      slot_end_utc = slot_start_utc + @duration
      unless time_slot_unavailable?(slot_start_utc, slot_end_utc) || booking_overlaps?(slot_start_utc, slot_end_utc)
        found_slots << slot_start_utc
      end
      slot_start_utc += SLOT_INTERVAL # Move to next 15-minute interval
    end
    found_slots
  end

  def find_first_valid_slot_in_period(period_start_utc, period_end_utc)
    slot_start_utc = period_start_utc.beginning_of_minute

    # Round to next 15-minute interval
    if slot_start_utc.min % 15 != 0
      rounded_min = (slot_start_utc.min / 15.0).ceil * 15
      if rounded_min >= 60
        slot_start_utc = (slot_start_utc + 1.hour).beginning_of_hour
      else
        slot_start_utc = slot_start_utc.change(min: rounded_min)
      end
    end

    while slot_start_utc + @duration <= period_end_utc
      slot_end_utc = slot_start_utc + @duration
      unless time_slot_unavailable?(slot_start_utc, slot_end_utc) || booking_overlaps?(slot_start_utc, slot_end_utc)
        return slot_start_utc
      end
      slot_start_utc += SLOT_INTERVAL # Move to next 15-minute interval
    end
    nil
  end

  # def combine_date_and_time_to_utc(date_obj, time_of_day_obj)
  #    return nil unless date_obj.is_a?(Date) && time_of_day_obj.respond_to?(:hour)
  #    @psych_tz.local(date_obj.year, date_obj.month, date_obj.day, time_of_day_obj.hour, time_of_day_obj.min, time_of_day_obj.sec || 0).utc
  # rescue ArgumentError => e
  #    Rails.logger.error "Error combining date and time: #{e.message}"
  #    nil
  # end
  def combine_date_and_time_to_utc(date_obj, time_of_day_obj)
    return nil unless date_obj.is_a?(Date) && time_of_day_obj.respond_to?(:hour)
    
    # Treat the stored hour/minute as local to the psychologist
    local_dt = @psych_tz.local(date_obj.year, date_obj.month, date_obj.day,
                              time_of_day_obj.hour, time_of_day_obj.min, time_of_day_obj.sec || 0)
    local_dt.utc
  rescue ArgumentError => e
    Rails.logger.error "Error combining date and time: #{e.message}"
    nil
  end

  def time_slot_unavailable?(start_time_utc, end_time_utc)
    start_in_psych_tz = start_time_utc.in_time_zone(@psych_tz)
    @psychologist.psychologist_unavailabilities.exists?([
      "(recurring = true AND day_of_week = ? AND (recurring_until IS NULL OR recurring_until >= ?)) OR (recurring = false AND (start_time, end_time) OVERLAPS (?, ?))",
      start_in_psych_tz.wday,
      start_in_psych_tz.to_date,
      start_time_utc,
      end_time_utc
    ])
  end

  def booking_overlaps?(start_time_utc, end_time_utc)
    @psychologist.bookings.where(status: ['confirmed', 'pending']).exists?(
      ["start_time < ? AND end_time > ?", end_time_utc, start_time_utc]
    )
  end
end