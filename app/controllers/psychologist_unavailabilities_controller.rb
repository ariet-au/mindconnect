# app/controllers/psychologist_unavailabilities_controller.rb
class PsychologistUnavailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_psychologist_profile
  before_action :set_time_zone, if: :psychologist_profile_and_timezone_present?

  def calendar
    @psychologist_profile = current_user.psychologist_profile
    unless @psychologist_profile
      redirect_to new_psychologist_profile_path, alert: "Please complete your profile first."
      return
    end
  end

  def calendar_bookings
    psychologist_profile_id = params[:psychologist_profile_id]

    bookings = Booking.includes(:service, :client_profile, :internal_client_profile)
                      .where(psychologist_profile_id: psychologist_profile_id)

    events = bookings.map do |booking|
      {
        id: booking.id,
        title: booking.service&.name || "Session",
        start: booking.start_time.iso8601,
        end: booking.end_time.iso8601,
        extendedProps: {
          client_name: booking.client_profile&.full_name || booking.internal_client_profile&.label || "N/A",
          status: booking.status,
          notes: booking.notes
        },
        color: booking.internal_client_profile_id.present? ? '#6f42c1' : '#0d6efd',
        textColor: 'white'
      }
    end

    render json: events
  end





  def index
    unavailabilities = PsychologistUnavailability.where(psychologist_profile_id: @psychologist_profile.id)

    non_recurring_events = unavailabilities.where(recurring: false).map do |unavailability|
      {
        id: unavailability.id,
        title: unavailability.reason,
        start: unavailability.start_time.iso8601, # UTC time
        end: unavailability.end_time.iso8601,     # UTC time
        recurring: false,
        timezone: unavailability.timezone
      }
    end

    recurring_unavailabilities = unavailabilities.where(recurring: true)
    all_events = non_recurring_events + generate_recurring_events(recurring_unavailabilities)

    render json: all_events
  end

  def create
    psychologist_profile_id = @psychologist_profile.id
    psychologist_timezone = @psychologist_profile.timezone 

    if params[:psychologist_unavailability][:recurring] == 'true'
      # For recurring events
      start_time_str = params[:psychologist_unavailability][:start_time]
      end_time_str = params[:psychologist_unavailability][:end_time]   

      # Parse in psychologist's timezone
      parsed_start_time = Time.find_zone(psychologist_timezone).parse(start_time_str)
      parsed_end_time = Time.find_zone(psychologist_timezone).parse(end_time_str)

      # Convert to UTC for storage
      processed_params = psychologist_unavailability_params.to_h.merge(
        psychologist_profile_id: psychologist_profile_id,
        start_time: parsed_start_time.utc,
        end_time: parsed_end_time.utc,
        timezone: psychologist_timezone
      )

      @psychologist_unavailability = PsychologistUnavailability.build_for_recurring(processed_params)
    else
      # For one-off events
      start_time_iso = params[:psychologist_unavailability][:start_time]
      end_time_iso = params[:psychologist_unavailability][:end_time]

      # Parse in psychologist's timezone
      parsed_start_time = Time.find_zone(psychologist_timezone).parse(start_time_iso)
      parsed_end_time = Time.find_zone(psychologist_timezone).parse(end_time_iso)

      # Convert to UTC for storage
      processed_params = psychologist_unavailability_params.to_h.merge(
        psychologist_profile_id: psychologist_profile_id,
        start_time: parsed_start_time.utc,
        end_time: parsed_end_time.utc,
        timezone: psychologist_timezone
      )
      @psychologist_unavailability = @psychologist_profile.psychologist_unavailabilities.new(processed_params)
    end

    if @psychologist_unavailability.save
      render json: {
        id: @psychologist_unavailability.id,
        title: @psychologist_unavailability.reason,
        start: @psychologist_unavailability.start_time, # UTC time
        end: @psychologist_unavailability.end_time,     # UTC time
        recurring: @psychologist_unavailability.recurring,
        allDay: false,
        timezone: @psychologist_unavailability.timezone,
        extendedProps: { recurring: @psychologist_unavailability.recurring }
      }, status: :created
    else
      render json: @psychologist_unavailability.errors, status: :unprocessable_entity
    end
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
      # Convert UTC times to psychologist's timezone for calculation
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
          # Create time in psychologist's timezone
          event_start = Time.find_zone(rule.timezone).local(date.year, date.month, date.day, start_hour, start_min)
          event_end = Time.find_zone(rule.timezone).local(date.year, date.month, date.day, end_hour, end_min)

          if event_end.hour < event_start.hour || (event_end.hour == event_start.hour && event_end.min < event_start.min)
            event_end += 1.day
          end

          if event_end >= Time.zone.now
            events << {
              id: rule.id,
              title: rule.reason,
              start: event_start.utc.iso8601, # Convert to UTC for FullCalendar
              end: event_end.utc.iso8601,     # Convert to UTC for FullCalendar
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