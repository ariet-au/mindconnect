# app/services/timezone_aware_slot_finder.rb
class TimezoneAwareSlotFinder
  def initialize(psychologist_profile_id, duration_minutes, user_timezone = 'UTC')
    @psychologist = PsychologistProfile.find(psychologist_profile_id)
    @duration = duration_minutes.minutes
    @user_timezone = user_timezone.presence || 'UTC'
    @psychologist_timezone = @psychologist.timezone.presence || 'UTC'
  end

  def next_available_slot(from_time = Time.current)
    # Safely get timezone object
    psych_tz = ActiveSupport::TimeZone[@psychologist_timezone] || ActiveSupport::TimeZone['UTC']
    
    # Convert input time to psychologist's timezone safely
    from_time_in_psych_tz = if from_time.respond_to?(:in_time_zone)
                              from_time.in_time_zone(psych_tz)
                            else
                              Time.current.in_time_zone(psych_tz)
                            end

    # Check the next 14 days (2 weeks) for availability
    (0..13).each do |day_offset|
      target_date = (from_time_in_psych_tz + day_offset.days).to_date
      day_of_week = target_date.wday

      @psychologist.psychologist_availabilities
                   .where(day_of_week: day_of_week)
                   .order(:start_time_of_day)
                   .each do |availability|
        
        start_time = combine_date_and_time(target_date, availability.start_time_of_day)
        end_time = combine_date_and_time(target_date, availability.end_time_of_day)
        next unless start_time && end_time

        # Adjust start time if it's in the past
        start_time = [start_time, from_time_in_psych_tz].max
        next if start_time >= end_time

        if slot_start = find_first_available_slot(start_time, end_time)
          return slot_start.in_time_zone(@user_timezone)
        end
      end
    end

    nil
  end

  private

  def combine_date_and_time(date, time_of_day)
    return nil unless date && time_of_day

    time_str = if time_of_day.respond_to?(:strftime)
                 time_of_day.strftime('%H:%M:%S')
               else
                 time_of_day.to_s
               end

    ActiveSupport::TimeZone[@psychologist_timezone].parse("#{date} #{time_str}")
  rescue ArgumentError, NoMethodError
    nil
  end

  def find_first_available_slot(start_time, end_time)
    slot_start = start_time
    
    while slot_start + @duration <= end_time
      slot_end = slot_start + @duration
      return slot_start unless time_slot_unavailable?(slot_start, slot_end)
      slot_start += 15.minutes
    end

    nil
  end

  def time_slot_unavailable?(start_time, end_time)
    @psychologist.psychologist_unavailabilities.exists?([
      "(recurring = true AND day_of_week = ? AND (recurring_until IS NULL OR recurring_until >= ?)) OR
      (recurring = false AND (start_time, end_time) OVERLAPS (?, ?))",
      start_time.wday,
      start_time.to_date,
      start_time,
      end_time
    ])
  end
end