# app/controllers/psychologist_unavailabilities_controller.rb
class PsychologistUnavailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_psychologist_profile
  before_action :set_time_zone, if: :psychologist_profile_and_timezone_present?

  def calendar
    @psychologist_profile = current_user.psychologist_profile if current_user
    unless @psychologist_profile
      redirect_to new_psychologist_profile_path, alert: "Please complete your profile first."
      return
    end
  end

  def index
    unavailabilities = PsychologistUnavailability.where(psychologist_profile_id: @psychologist_profile.id)

    non_recurring_events = unavailabilities.where(recurring: false).map do |unavailability|
      {
        id: unavailability.id,
        title: unavailability.reason,
        start: unavailability.start_time.in_time_zone(unavailability.timezone).iso8601,
        end: unavailability.end_time.in_time_zone(unavailability.timezone).iso8601,
        recurring: false,
        timezone: unavailability.timezone
      }
    end

    recurring_unavailabilities = unavailabilities.where(recurring: true)

    all_events = non_recurring_events + generate_recurring_events(recurring_unavailabilities)

    render json: all_events
  end

def create
  # Assuming @psychologist_profile is already set
  psychologist_profile_id = @psychologist_profile.id
  psychologist_timezone = @psychologist_profile.timezone # Or params[:psychologist_unavailability][:timezone]

  # Set the current Time.zone for parsing based on the psychologist's timezone
  original_time_zone = Time.zone
  Time.zone = psychologist_timezone

  if params[:psychologist_unavailability][:recurring] == 'true'
    # For recurring events, the 'start_time' and 'end_time' from the frontend
    # are based on a DUMMY_DATE but should represent the time of day in the psychologist's TZ.
    # Extract just the time component or parse carefully.

    # Example: Input "2000-01-01T08:00:00"
    # We want to ensure 08:00 is interpreted as AM.
    start_time_str = params[:psychologist_unavailability][:start_time] # e.g., "2000-01-01T08:00:00"
    end_time_str = params[:psychologist_unavailability][:end_time]   # e.g., "2000-01-01T09:00:00"

    # Explicitly parse to avoid ambiguity with AM/PM for "HH:MM:SS"
    # If your input is always "YYYY-MM-DDTHH:MM:SS", then Time.zone.parse should be fine,
    # but if there's a locale issue, you might need more explicit parsing.
    # Let's try parsing the full string assuming it's in the set Time.zone
    parsed_start_time = Time.zone.parse(start_time_str)
    parsed_end_time = Time.zone.parse(end_time_str)

    Rails.logger.debug "Recurring input start_time_str: #{start_time_str}"
    Rails.logger.debug "Recurring parsed_start_time (in #{Time.zone.name}): #{parsed_start_time.inspect}"
    Rails.logger.debug "Recurring parsed_start_time UTC: #{parsed_start_time.utc.inspect}"

    processed_params = psychologist_unavailability_params.to_h.merge(
      psychologist_profile_id: psychologist_profile_id,
      start_time: parsed_start_time, # Use the parsed time object
      end_time: parsed_end_time,     # Use the parsed time object
      timezone: psychologist_timezone
    )

    @psychologist_unavailability = PsychologistUnavailability.build_for_recurring(processed_params)
  else
    # For one-off events, the 'start_time' and 'end_time' from FullCalendar
    # are already ISO strings representing the selected time in the psychologist's timezone
    # (because FullCalendar's timeZone is set to psychologistTimeZone during selection).
    # So, Time.zone.parse will correctly interpret them.

    start_time_iso = params[:psychologist_unavailability][:start_time] # This comes as ISO from FullCalendar select
    end_time_iso = params[:psychologist_unavailability][:end_time]     # This comes as ISO from FullCalendar select

    parsed_start_time = Time.zone.parse(start_time_iso)
    parsed_end_time = Time.zone.parse(end_time_iso)

    Rails.logger.debug "One-off input start_time_iso: #{start_time_iso}"
    Rails.logger.debug "One-off parsed_start_time (in #{Time.zone.name}): #{parsed_start_time.inspect}"
    Rails.logger.debug "One-off parsed_start_time UTC: #{parsed_start_time.utc.inspect}"

    processed_params = psychologist_unavailability_params.to_h.merge(
      psychologist_profile_id: psychologist_profile_id,
      start_time: parsed_start_time,
      end_time: parsed_end_time,
      timezone: psychologist_timezone
    )
    @psychologist_unavailability = @psychologist_profile.psychologist_unavailabilities.new(processed_params)
  end

  if @psychologist_unavailability.save
    render json: {
      id: @psychologist_unavailability.id,
      title: @psychologist_unavailability.reason,
      # Ensure these are converted to the psychologist's timezone for the ISO string output
      start: @psychologist_unavailability.start_time.in_time_zone(@psychologist_unavailability.timezone).iso8601,
      end: @psychologist_unavailability.end_time.in_time_zone(@psychologist_unavailability.timezone).iso8601,
      recurring: @psychologist_unavailability.recurring,
      allDay: false,
      timezone: @psychologist_unavailability.timezone,
      # Add extendedProps if you have them for debugging/info
      extendedProps: { recurring: @psychologist_unavailability.recurring }
    }, status: :created
  else
    render json: @psychologist_unavailability.errors, status: :unprocessable_entity
  end
ensure
  # Restore original time zone after the request to avoid side effects
  Time.zone = original_time_zone
end

  def destroy
    @psychologist_unavailability = PsychologistUnavailability.find(params[:id])
    if @psychologist_unavailability.psychologist_profile != @psychologist_profile
      render json: { error: "Unauthorized" }, status: :unauthorized and return
    end

    if @psychologist_unavailability.destroy
      head :no_content
    else
      render json: @psychologist_unavailability.errors, status: :unprocessable_entity
    end
  end

  private

  def set_psychologist_profile
    @psychologist_profile = current_user.psychologist_profile
    unless @psychologist_profile
      render json: { error: "Psychologist profile not found." }, status: :not_found and return
    end
  end

  def set_time_zone
    Time.zone = @psychologist_profile.timezone
  end

  def psychologist_profile_and_timezone_present?
    @psychologist_profile.present? && @psychologist_profile.timezone.present?
  end

  def generate_recurring_events(recurring_unavailabilities)
    events = []
    current_date_in_psych_zone = Time.zone.now.to_date
    end_date_for_generation = [current_date_in_psych_zone + 1.year, Date.new(2030, 12, 31)].min

    recurring_unavailabilities.each do |rule|
      start_time_in_rule_zone = rule.start_time.in_time_zone(rule.timezone)
      end_time_in_rule_zone = rule.end_time.in_time_zone(rule.timezone)

      start_hour = start_time_in_rule_zone.hour
      start_min = start_time_in_rule_zone.min
      end_hour = end_time_in_rule_zone.hour
      end_min = end_time_in_rule_zone.min

      effective_recurring_until = rule.recurring_until.present? ? [rule.recurring_until.to_date, end_date_for_generation].min : end_date_for_generation

      start_date_for_iteration = [current_date_in_psych_zone, rule.start_time.in_time_zone(rule.timezone).to_date].max

      (start_date_for_iteration..effective_recurring_until).each do |date|
        if date.wday == rule.day_of_week
          event_start = Time.zone.local(date.year, date.month, date.day, start_hour, start_min)
          event_end = Time.zone.local(date.year, date.month, date.day, end_hour, end_min)

          if event_end.hour < event_start.hour || (event_end.hour == event_start.hour && event_end.min < event_start.min)
            event_end += 1.day
          end

          if event_end >= Time.zone.now
            events << {
              id: rule.id,
              title: rule.reason,
              start: event_start.iso8601,
              end: event_end.iso8601,
              allDay: false,
              recurring: true,
              timezone: rule.timezone
            }
          end
        end
      end
    end
    events
  end

  def psychologist_unavailability_params
    params.require(:psychologist_unavailability).permit(
      :start_time, :end_time, :reason, :recurring, :day_of_week,
      :recurring_until
    )
  end
end