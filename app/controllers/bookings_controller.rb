# app/controllers/bookings_controller.rb
require_relative '../models/booking' # <--- ADDED THIS LINE
require 'icalendar'
require 'tzinfo'
require 'icalendar/tzinfo'


class BookingsController < ApplicationController
  #skip_before_action :set_psychologist_profile, only: [:dynamic_select]
  before_action :authenticate_user!, except: [:confirm_form, :confirm]
  before_action :set_booking, only: [:show, :edit, :update, :destroy]
  #before_action :set_psychologist_profile, only: [:create_json, :update_json, :destroy_json, :new]


  def index
    @psychologist_profile = current_user.psychologist_profile
    if @psychologist_profile
      @bookings = Booking.where(psychologist_profile_id: @psychologist_profile.id)
    else
      redirect_to new_psychologist_profile_path, alert: "Please complete your profile first."
    end
  end

  def show
    @booking = Booking.find(params[:id])
    respond_to do |format|
      format.html # Render HTML view if requested (e.g., for /bookings/:id)
      format.json do
        render json: {
          id: @booking.id,
          status: @booking.status,
          client: @booking.client_profile ? { full_name: @booking.client_profile.full_name } : nil,
          internal_client: @booking.internal_client_profile ? { full_name: @booking.internal_client_profile.full_name } : nil,
          service: @booking.service ? { name: @booking.service.name } : nil,
          start_time: @booking.start_time.iso8601,
          end_time: @booking.end_time.iso8601
        }
      end
    end
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { render plain: "Booking not found", status: :not_found }
        format.json { render json: { error: "Booking not found" }, status: :not_found }
      end
  end

  def new
    @service = Service.find(params[:service_id])
    @psychologist_profile = @service.user.psychologist_profile
    
    # Determine the timezone for display
    # Prioritize browser timezone, then session, cookies, psychologist's timezone, fallback to 'UTC'
    @display_timezone = params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] || @psychologist_profile.timezone.presence || 'UTC'
    
    # Initialize the slot finder
    # Pass the psychologist's timezone to the slot finder as it needs to know the source timezone
    slot_finder = SlotFinder.new(
      @psychologist_profile.id,
      @service.duration_minutes,
      @psychologist_profile.timezone # Use psychologist's timezone for slot calculation logic
    )

    # Find ALL available slots for the view, converted to display_timezone for presentation
    # The SlotFinder should return slots in UTC, then we convert for display
    raw_available_slots = slot_finder.all_available_slots_by_day

    # Convert slots to the @display_timezone for the view
    @available_slots = {}
    raw_available_slots.each do |date, slots|
      @available_slots[date] = slots.map { |slot| slot.in_time_zone(@display_timezone) }
    end

    @available_slots ||= {} # Ensure it's an empty hash if no slots are found

    next_slot_utc = slot_finder.next_available_slot(Time.current.in_time_zone(@display_timezone))
    @next_available_time = next_slot_utc&.in_time_zone(@display_timezone) # Convert to display timezone

    @booking_start_time_for_form = @next_available_time || (Time.current.in_time_zone(@display_timezone).beginning_of_hour + 1.hour)

    # Build the booking object
    @booking = Booking.new(
      service: @service,
      psychologist_profile: @psychologist_profile,
      start_time: @booking_start_time_for_form.utc
    )
    
    if current_user.client? && current_user.client_profile.present?
      @booking.client_profile_id = current_user.client_profile.id
    end
    # Calculate end_time for display purposes
    @booking.end_time = @booking.start_time + @service.duration_minutes.minutes if @booking.start_time
    
    # This is needed for the JavaScript to correctly calculate UTC time from the user's selected time
    # This offset is for the @display_timezone relative to UTC
    @display_timezone_offset_seconds = ActiveSupport::TimeZone.new(@display_timezone).utc_offset if @display_timezone
    
    # Prepare collections for client selection in the view
    @external_clients = ClientProfile.all # Adjust scope as needed, e.g., current_user.clients
    @internal_clients = InternalClientProfile.all # Adjust scope as needed
  end

  def new_with_service_selection
    @psychologist_profile = PsychologistProfile.find(params[:psychologist_profile_id])
    
    # Determine the timezone for display
    @display_timezone = params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] || @psychologist_profile.timezone.presence || 'UTC'
    
    # Get all services for this psychologist
    @services = @psychologist_profile.services # Assuming you have an active scope
    
    # Set default service or get from params
    @selected_service = if params[:service_id].present?
      @services.find(params[:service_id])
    else
      @services.first
    end
    
    # Initialize available slots if we have a service
    @available_slots = {}
    @next_available_time = nil
    
    if @selected_service
      # Initialize the slot finder with the selected service duration
      slot_finder = SlotFinder.new(
        @psychologist_profile.id,
        @selected_service.duration_minutes,
        @psychologist_profile.timezone
      )
      
      # Find available slots - we'll convert these to simple time options
      raw_available_slots = slot_finder.all_available_slots_by_day
      
      # Convert to simple array of available start times for dropdown
      @available_start_times = []
      raw_available_slots.each do |date, slots|
        slots.each do |slot|
          @available_start_times << slot.utc
        end
      end
      
      # Sort by time
      @available_start_times.sort!
      
      # Get next available slot
      next_slot_utc = slot_finder.next_available_slot(Time.current)
      @next_available_time = next_slot_utc
    end
    
    # Build the booking object
    @booking = Booking.new(
      service: @selected_service,
      psychologist_profile: @psychologist_profile,
      start_time: @next_available_time
    )
    
    if current_user.client? && current_user.client_profile.present?
      @booking.client_profile_id = current_user.client_profile.id
    end
    
    # Calculate end_time if we have a start_time and service
    if @booking.start_time && @selected_service
      @booking.end_time = @booking.start_time + @selected_service.duration_minutes.minutes
    end
    
    # Prepare collections for client selection in the view
    @external_clients = ClientProfile.all
    @internal_clients = @psychologist_profile.internal_client_profiles # Assuming you have a scope for internal clients
  end
  # app/controllers/psychologist_profiles_controller.rb
# app/controllers/psychologist_profiles_controller.rb
  def available_slots
    @psychologist_profile = PsychologistProfile.find(params[:id])
    service = Service.find(params[:service_id])
    timezone = params[:browser_timezone] || 'UTC'

    slot_finder = SlotFinder.new(
      @psychologist_profile.id,
      service.duration_minutes,
      @psychologist_profile.timezone
    )

    # Get all available slots (UTC times)
    raw_slots = slot_finder.all_available_slots_by_day.values.flatten

    # Format for JSON response
    available_slots = raw_slots.map do |slot|
      {
        utc: slot.utc.iso8601,
        local: slot.in_time_zone(timezone).strftime("%a, %b %d at %H:%M")
      }
    end

    render json: { available_slots: available_slots }
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def edit
  end

  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.json { render json: { success: true }, status: :ok }
        # Corrected redirect_to line
        format.html { redirect_to [@booking.psychologist_profile, @booking], notice: 'Booking was successfully updated.' }
      else
        format.json { render json: { success: false, error: @booking.errors.full_messages.join(', ') }, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @booking.destroy
    redirect_to bookings_path, notice: 'Booking was successfully deleted.'
  end

  def create_json
    @booking = @psychologist_profile.bookings.new(booking_params)
    @booking.created_by = 'psychologist' if current_user.psychologist?
    @booking.timezone = @psychologist_profile.timezone

    if booking_conflicts?
      render json: { success: false, error: "The selected time slot is not available." }, status: :unprocessable_entity
      return
    end

    if @booking.save
      render json: { success: true, id: @booking.id }, status: :created
    else
      render json: { success: false, error: @booking.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def update_json
    if booking_conflicts?
      render json: { success: false, error: "The selected time slot is not available." }, status: :unprocessable_entity
      return
    end

    if @booking.update(booking_params)
      render json: { success: true, id: @booking.id }, status: :ok
    else
      render json: { success: false, error: @booking.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def destroy_json
    @booking = Booking.find(params[:id])
    if @booking.psychologist_profile_id.to_s == params[:psychologist_profile_id] && @booking.destroy
      render json: { success: true }, status: :ok
    else
      render json: { success: false, error: @booking.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def calendar_bookings
    psychologist_profile = PsychologistProfile.find(params[:psychologist_profile_id])
    bookings = Booking.where(psychologist_profile_id: psychologist_profile.id)
                      .where('start_time >= ?', Time.current.beginning_of_day)
                      .order(:start_time)
                      .includes(:service, :client_profile)

      render json: bookings.map { |booking| booking_to_event(booking) }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Psychologist profile not found" }, status: :not_found
  end


  def confirm_form
    @booking = Booking.find_by(id: params[:id], confirmation_token: params[:token])

    if @booking.nil?
      redirect_to root_path, alert: "Invalid or expired link"
    else
      # Render a separate view for token users
      render :confirm_form_client
    end
  end

  def confirm
    @booking = Booking.find_by(id: params[:id], confirmation_token: params[:token])

    if @booking.nil?
      redirect_to root_path, alert: "Invalid or expired link"
      return
    end

    if @booking.pending?
      @booking.update(status: 'confirmed', confirmation_token: nil)
      flash[:notice] = "Booking confirmed successfully."
    else
      flash[:alert] = "Booking cannot be confirmed."
    end

    render :confirm_form_client
  end


def decline
  @booking = Booking.find(params[:id])
  if (params[:token].present? && @booking.confirmation_token == params[:token]) ||
      (current_user&.psychologist? && @booking.psychologist_profile.user == current_user)
    if @booking.pending?
      @booking.update(status: 'declined', confirmation_token: nil) if params[:token].present?
      @booking.update(status: 'declined') unless params[:token].present?
      
      # Corrected redirect
      redirect_to [@booking.psychologist_profile, @booking], notice: 'Booking declined successfully.'
    else
      redirect_to [@booking.psychologist_profile, @booking], alert: 'Booking cannot be declined.'
    end
  else
    redirect_to root_path, alert: 'Unauthorized to decline this booking.'
  end
end


  def psychologist_bookings
    if current_user&.psychologist_profile
      @bookings = Booking.includes(:client_profile, :internal_client_profile, :service)
                     .where(psychologist_profile_id: current_user.psychologist_profile.id)
                     .order(start_time: :desc)
    else
      redirect_to root_path, alert: "You must be logged in as a psychologist to view this page."
    end
  end


  def select_service
    @services = current_user.services
    # Set psychologist_id based on current user if psychologist
    @psychologist_id = current_user.psychologist_profile&.id if current_user.role == "psychologist"
  end

  def choose_time
    @psychologist = if params[:psychologist_id].present?
                      PsychologistProfile.find(params[:psychologist_id])
                    elsif current_user.role == "psychologist"
                      current_user.psychologist_profile || raise(ActiveRecord::RecordNotFound, "No psychologist profile found for current user")
                    else
                      raise ActiveRecord::RecordNotFound, "Psychologist ID is required"
                    end

    @service = Service.find(params[:service_id])

    slot_finder = SlotFinder.new(@psychologist.id, @service.duration_minutes, Time.zone.name)
    @time_slots = slot_finder.all_available_slots_by_day(Time.current, 14)

    # Optional debug
    @time_slots.each do |date, slots|
      formatted_slots = slots.map { |s| s.in_time_zone(@psychologist.timezone).strftime('%H:%M %Z') }
      Rails.logger.debug "Available slots for #{date}: #{formatted_slots}"
    end
  end



  def assign_client
    @booking = Booking.new
    @psychologist = PsychologistProfile.find(params[:psychologist_id])
    @service = Service.find(params[:service_id])
    #@selected_time = Time.zone.parse(params[:selected_time])
    @selected_time = Time.zone.parse("#{params[:date]} #{params[:selected_time]}")

    if current_user.role == "psychologist"
      @clients = current_user.psychologist_profile.internal_client_profiles
    else
      @client = current_user.internal_client_profile # Assuming a single profile per client user
    end
  end

  def edit_time
    # Find psychologist and service
    @psychologist = if params[:psychologist_id].present?
                      PsychologistProfile.find(params[:psychologist_id])
                    elsif current_user.role == "psychologist"
                      current_user.psychologist_profile || raise(ActiveRecord::RecordNotFound, "No psychologist profile found for current user")
                    else
                      raise ActiveRecord::RecordNotFound, "Psychologist ID is required"
                    end

    @service = Service.find(params[:service_id])

    # Find the booking being edited
    @booking = Booking.find(params[:booking_id])

    # Initialize SlotFinder
    slot_finder = SlotFinder.new(@psychologist.id, @service.duration_minutes, Time.zone.name)

    # Exclude current booking from overlap checks
    @time_slots = slot_finder.all_available_slots_by_day(Time.current, 14).transform_values do |slots|
      slots.reject { |s| s.utc == @booking.start_time.utc }
    end

    # Optional debug log
    @time_slots.each do |date, slots|
      formatted_slots = slots.map { |s| s.in_time_zone(@psychologist.timezone).strftime('%H:%M %Z') }
      Rails.logger.debug "Available slots for #{date}: #{formatted_slots}"
    end

    # Pre-select existing booking slot in the view (JavaScript can highlight it)
  end

  def confirm_booking
    @psychologist = PsychologistProfile.find(params[:psychologist_id])
    @service = Service.find(params[:service_id])

    # --- MODIFIED LINE ---
    # Combine the date and time strings before parsing
    date_string = params[:date]
    time_string = params[:selected_time]
    #@selected_time = Time.zone.parse("#{date_string} #{time_string}")
    @selected_time = Time.zone.parse("#{params[:date]} #{params[:selected_time]}")

    # Determine the client based on user role
    if current_user.role == "psychologist" && params[:client_id].present?
      @internal_client = InternalClientProfile.find(params[:client_id])
      @client_profile = nil
    else
      @internal_client = current_user.internal_client_profile
      @client_profile = nil
    end

    # Set created_by based on user role
    created_by = current_user.role == "psychologist" ? "psychologist" : "client"

    booking = Booking.new(
      psychologist_profile: @psychologist,
      service: @service,
      internal_client_profile: @internal_client,
      client_profile: @client_profile,
      start_time: @selected_time,
      end_time: @selected_time + @service.duration_minutes.minutes,
      status: "pending",
      created_by: created_by
    )

    if booking.save
      redirect_to psychologist_profile_booking_path(booking.psychologist_profile, booking), notice: "Booking confirmed!"
    else
      redirect_to select_service_path, alert: "Failed to create booking: #{booking.errors.full_messages.join(', ')}"
    end
  end


  def download_ics
    booking = Booking.find(params[:id])
    psychologist = booking.psychologist_profile

    # Fall back to UTC if you don’t store timezone per psychologist
    tzid = psychologist&.timezone || "Australia/Sydney"
    tz = TZInfo::Timezone.get(tzid)

    cal = Icalendar::Calendar.new

    # Add timezone info to calendar
    timezone = tz.ical_timezone(booking.start_time)
    cal.add_timezone(timezone)

    cal.event do |e|
      e.dtstart     = Icalendar::Values::DateTime.new(booking.start_time, 'tzid' => tzid)
      e.dtend       = Icalendar::Values::DateTime.new(booking.end_time, 'tzid' => tzid)
      e.summary     = booking.service&.name || "Therapy Session"
      e.description = "Session with #{psychologist&.full_name}"
      e.location    = psychologist&.address
    end

    send_data cal.to_ical,
              type: 'text/calendar',
              disposition: 'attachment',
              filename: "booking-#{booking.id}.ics"
  end

  private

  def calculate_available_times(psychologist, date, service_duration)
    available_times = []
    return available_times unless date

    # Get all availability entries for that weekday
    availabilities = PsychologistAvailability.where(
      psychologist_profile: psychologist,
      day_of_week: date.wday
    )

    # Get all unavailability entries that intersect the date, converted to UTC.
    unavailabilities = PsychologistUnavailability
      .where(psychologist_profile: psychologist)
      .where("start_time < ? AND end_time > ?", date.end_of_day.utc, date.beginning_of_day.utc)
      .map { |u| { start_time: u.start_time.utc, end_time: u.end_time.utc } }

    availabilities.each do |avail|
      # FIX: This section has been updated.
      # The start_time_of_day from the database is a UTC time with a dummy date.
      # We first convert this UTC time to the psychologist's local timezone.
      # This prevents a double conversion and ensures the correct local hour/minute are used.
      timezone_object = ActiveSupport::TimeZone[avail.timezone]
      
      start_time_local_from_avail = avail.start_time_of_day.in_time_zone(timezone_object)
      end_time_local_from_avail   = avail.end_time_of_day.in_time_zone(timezone_object)

      start_time_local = timezone_object.local(date.year, date.month, date.day, start_time_local_from_avail.hour, start_time_local_from_avail.min)
      end_time_local   = timezone_object.local(date.year, date.month, date.day, end_time_local_from_avail.hour, end_time_local_from_avail.min)

      # Convert these local times to UTC for all comparisons
      start_time = start_time_local.utc
      end_time   = end_time_local.utc

      current_time = start_time
      # Loop with a 30-minute interval, as requested
      while current_time + service_duration.minutes <= end_time
        slot_end = current_time + service_duration.minutes

        # Check for overlap with unavailabilities
        overlaps_unavailability = unavailabilities.any? do |u|
          u[:start_time] < slot_end && u[:end_time] > current_time
        end

        # Check for overlap with existing bookings
        overlaps_booking = Booking.where(psychologist_profile: psychologist)
                                  .where.not(status: ['declined', 'cancelled'])
                                  .where("start_time < ? AND end_time > ?", slot_end, current_time)
                                  .exists?

        unless overlaps_unavailability || overlaps_booking
          available_times << current_time
        end

        # Always increment by 30 minutes to get the next start time
        current_time += 30.minutes
      end
    end
    available_times
  end




  def booking_conflicts?
    start_time = @booking.start_time
    end_time = @booking.end_time
    psychologist_profile_id = @booking.psychologist_profile_id

    overlapping_bookings = Booking.where(psychologist_profile_id: psychologist_profile_id)
                                 .where.not(id: @booking.id)
                                 .where.not(status: ['declined', 'cancelled'])
                                 .where('start_time < ? AND end_time > ?', end_time, start_time)
    return true if overlapping_bookings.exists?

    overlapping_unavailabilities = PsychologistUnavailability.where(psychologist_profile_id: psychologist_profile_id)
                                                             .where('start_time < ? AND end_time > ?', end_time, start_time)
    return true if overlapping_unavailabilities.exists?

    start_in_zone = start_time.in_time_zone(@psychologist_profile.timezone)
    day_of_week = start_in_zone.wday
    start_minutes = start_in_zone.hour * 60 + start_in_zone.min
    end_minutes = end_time.in_time_zone(@psychologist_profile.timezone).hour * 60 + end_time.in_time_zone(@psychologist_profile.timezone).min

    available = PsychologistAvailability.where(psychologist_profile_id: psychologist_profile_id)
                                       .where(day_of_week: day_of_week)
                                       .where('start_time <= ? AND end_time >= ?', start_minutes, end_minutes)
    available.exists? # Fixed: Return true if within availability
  end


  def booking_to_event(booking)
    client_name = booking.client_profile&.full_name || booking.internal_client_profile&.label || "N/A"
    {
      id: booking.id,
      title: "#{booking.service&.name || 'Session'} - #{client_name} (#{booking.created_by})",
      start: booking.start_time.iso8601,
      end: booking.end_time.iso8601,
      extendedProps: {
        bookingId: booking.id,
        clientName: client_name,
        status: booking.status,
        notes: booking.notes,
        created_by: booking.created_by,
        service_name: booking.service&.name,
        confirmation_token: booking.confirmation_token
      },
      color: booking.internal_client_profile_id.present? ? '#6f42c1' : '#0d6efd',
      textColor: 'white'
    }
  end

  def set_booking
    @booking = Booking.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: "Booking not found" }, status: :not_found
    false # This ensures the action stops if the booking isn't found
  end

  def set_psychologist_profile
    @psychologist_profile = current_user.psychologist_profile
    unless @psychologist_profile
      render json: { error: "Psychologist profile not found." }, status: :not_found
    end
  end

  def booking_params
    params.require(:booking).permit(
      :psychologist_profile_id,
      :client_profile_id,
      :internal_client_profile_id,
      :notes,
      :service_id,
      :start_time,
      :end_time,
      :status,
      :created_by,
      :confirmation_token
    )
  end
end
