class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  def index
    @bookings = Booking.includes(:psychologist_profile, :client_profile, :internal_client_profile, :service).all
  end

  def show
  end

  def new
    @service = Service.find(params[:service_id])
    @psychologist_profile = @service.user.psychologist_profile
    
    # Determine the timezone for display
    # Prioritize browser timezone, then session, cookies, psychologist's timezone, fallback to 'UTC'
    @display_timezone = params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] || @psychologist_profile.timezone.presence || 'UTC'
    
    # Initialize the slot finder
    # Pass the psychologist's timezone to the slot finder as it needs to know the source timezone
    slot_finder = TimezoneAwareSlotFinder.new(
      @psychologist_profile.id,
      @service.duration_minutes,
      @psychologist_profile.timezone # Use psychologist's timezone for slot calculation logic
    )

    # Find ALL available slots for the view, converted to display_timezone for presentation
    # The TimezoneAwareSlotFinder should return slots in UTC, then we convert for display
    raw_available_slots = slot_finder.all_available_slots_by_day

    # Convert slots to the @display_timezone for the view
    @available_slots = {}
    raw_available_slots.each do |date, slots|
      # Convert the date key itself to the display timezone for consistency if needed,
      # but typically the date key is just a date, not a time.
      # For the slots (Time objects), convert them to the display timezone.
      @available_slots[date] = slots.map { |slot| slot.in_time_zone(@display_timezone) }
    end

    @available_slots ||= {} # Ensure it's an empty hash if no slots are found

    # Find the NEXT available slot to use as a default selection
    # This slot should also be converted to the @display_timezone for presentation
    next_slot_utc = slot_finder.next_available_slot(Time.current.in_time_zone(@display_timezone))
    @next_available_time = next_slot_utc&.in_time_zone(@display_timezone) # Convert to display timezone

    # If no slots are available at all, handle this gracefully
    # Use the current time in the display timezone, rounded up to the next hour
    @booking_start_time_for_form = @next_available_time || (Time.current.in_time_zone(@display_timezone).beginning_of_hour + 1.hour)

    # Build the booking object
    @booking = Booking.new(
      service: @service,
      psychologist_profile: @psychologist_profile,
      status: current_user.psychologist? ? 'confirmed' : 'pending',
      # The start_time for the booking record should be in UTC
      start_time: @booking_start_time_for_form.utc
    )
    
    # --- NEW LOGIC ADDED HERE ---
    # If the current user is a client, automatically set the client_profile_id
    if current_user.client? && current_user.client_profile.present?
      @booking.client_profile_id = current_user.client_profile.id
    end
    # --- END NEW LOGIC ---

    # Calculate end_time for display purposes
    @booking.end_time = @booking.start_time + @service.duration_minutes.minutes if @booking.start_time
    
    # This is needed for the JavaScript to correctly calculate UTC time from the user's selected time
    # This offset is for the @display_timezone relative to UTC
    @display_timezone_offset_seconds = ActiveSupport::TimeZone.new(@display_timezone).utc_offset if @display_timezone
    
    # Prepare collections for client selection in the view
    @external_clients = ClientProfile.all # Adjust scope as needed, e.g., current_user.clients
    @internal_clients = InternalClientProfile.all # Adjust scope as needed
  end

  def create
    @booking = Booking.new(booking_params)

    if current_user.psychologist?
      @booking.psychologist_profile_id ||= current_user.psychologist_profile.id
    else
      @booking.client_profile_id = current_user.client_profile.id
    end

    if @booking.save
      Rails.logger.info("Booking created successfully, redirecting...")
      redirect_to @booking, notice: "Booking created successfully."
    else
      @service = @booking.service || Service.find(params[:booking][:service_id])
      @psychologist_profile = @booking.psychologist_profile || @service.user.psychologist_profile

      psych_timezone = @psychologist_profile.timezone.presence || 'UTC'
      @display_timezone = params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] || psych_timezone
      user_tz_obj = ActiveSupport::TimeZone[@display_timezone] || ActiveSupport::TimeZone['UTC']
      
      @next_available_time = @booking.start_time || Time.current.in_time_zone(user_tz_obj)
      # Corrected line for calculating display_timezone_offset_seconds on re-render
      @display_timezone_offset_seconds = @next_available_time.period.utc_total_offset

      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @booking.update(booking_params)
      redirect_to @booking, notice: 'Booking was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @booking.destroy
    redirect_to bookings_path, notice: 'Booking was successfully deleted.'
  end

  def calendar_bookings
    psychologist_profile = PsychologistProfile.find(params[:psychologist_profile_id])
    bookings = Booking.where(psychologist_profile_id: psychologist_profile.id)
                      .where('start_time >= ?', Time.current.beginning_of_day)
                      .order(:start_time)
                      .includes(:service, :client_profile)

    render json: bookings.map { |booking| booking_to_event(booking) }
  end

  private

  def booking_to_event(booking)
    client_name = booking.client_profile&.full_name || 'Unknown Client'
    service_name = booking.service&.name || 'Unknown Service'

    {
      id: booking.id,
      title: "#{service_name} with #{client_name}",
      start: booking.start_time.iso8601,
      end: booking.end_time.iso8601,
      color: '#0d6efd',
      textColor: 'white',
      extendedProps: {
        status: booking.status,
        notes: booking.notes,
        client_profile_id: booking.client_profile_id,
        service_id: booking.service_id
      }
    }
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(
      :psychologist_profile_id,
      :client_profile_id,
      :internal_client_profile_id,
      :service_id,
      :start_time,
      :end_time,
      :status,
      :notes
    )
  end
end