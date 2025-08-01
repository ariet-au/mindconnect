class BookingsController < ApplicationController
  before_action :authenticate_user!, except: [:confirm_form, :confirm]
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

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
      start_time: @booking_start_time_for_form.utc
    )
    
    # --- NEW LOGIC ADDED HERE ---
    # If the current user is a client, automatically set the client_profile_id
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

  # def create
  #   @booking = Booking.new(booking_params)

  #   if current_user.psychologist?
  #     @booking.psychologist_profile_id ||= current_user.psychologist_profile.id
  #   else
  #     @booking.client_profile_id = current_user.client_profile.id
  #   end

  #   if @booking.save
  #     Rails.logger.info("Booking created successfully, redirecting...")
  #     redirect_to @booking, notice: "Booking created successfully."
  #   else
  #     @service = @booking.service || Service.find(params[:booking][:service_id])
  #     @psychologist_profile = @booking.psychologist_profile || @service.user.psychologist_profile

  #     psych_timezone = @psychologist_profile.timezone.presence || 'UTC'
  #     @display_timezone = params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] || psych_timezone
  #     user_tz_obj = ActiveSupport::TimeZone[@display_timezone] || ActiveSupport::TimeZone['UTC']
      
  #     @next_available_time = @booking.start_time || Time.current.in_time_zone(user_tz_obj)
  #     # Corrected line for calculating display_timezone_offset_seconds on re-render
  #     @display_timezone_offset_seconds = @next_available_time.period.utc_total_offset

  #     render :new, status: :unprocessable_entity
  #   end
  # end
  def create
    @booking = Booking.new(booking_params)
    @booking.created_by = current_user.psychologist? ? 'psychologist' : 'client'

    if current_user.psychologist?
      @booking.psychologist_profile_id ||= current_user.psychologist_profile.id
    else
      @booking.client_profile_id = current_user.client_profile.id
    end

    if @booking.save
      Rails.logger.info("Booking created successfully, redirecting...")
      if @booking.created_by == 'psychologist'
        redirect_to @booking, notice: "Booking created successfully. Share the confirmation link with the client."
      else
        redirect_to @booking, notice: "Booking created successfully. Awaiting psychologist confirmation."
      end
    else
      @service = @booking.service || Service.find(params[:booking][:service_id])
      @psychologist_profile = @booking.psychologist_profile || @service.user.psychologist_profile
      psych_timezone = @psychologist_profile.timezone.presence || 'UTC'
      @display_timezone = params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] || psych_timezone
      user_tz_obj = ActiveSupport::TimeZone[@display_timezone] || ActiveSupport::TimeZone['UTC']
      @next_available_time = @booking.start_time || Time.current.in_time_zone(user_tz_obj)
      @display_timezone_offset_seconds = @next_available_time.utc_total_offset
      render :new, status: :unprocessable_entity
    end
  end


  def edit
  end

  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.json { render json: { success: true }, status: :ok }
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
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
    if @booking.destroy
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
    @booking = Booking.find(params[:id])
    if @booking.confirmation_token == params[:token] && @booking.pending?
      # Render confirmation form (details below)
    else
      redirect_to root_path, alert: 'Invalid or expired token'
    end
  end

  def confirm
    @booking = Booking.find(params[:id])
    if (params[:token].present? && @booking.confirmation_token == params[:token]) ||
       (current_user&.psychologist? && @booking.psychologist_profile.user == current_user)
      if @booking.pending?
        @booking.update(status: 'confirmed', confirmation_token: nil) if params[:token].present?
        @booking.update(status: 'confirmed') unless params[:token].present?
        redirect_to @booking, notice: 'Booking confirmed successfully.'
      else
        redirect_to @booking, alert: 'Booking cannot be confirmed.'
      end
    else
      redirect_to root_path, alert: 'Unauthorized to confirm this booking.'
    end
  end

  def decline
    @booking = Booking.find(params[:id])
    if (params[:token].present? && @booking.confirmation_token == params[:token]) ||
       (current_user&.psychologist? && @booking.psychologist_profile.user == current_user)
      if @booking.pending?
        @booking.update(status: 'declined', confirmation_token: nil) if params[:token].present?
        @booking.update(status: 'declined') unless params[:token].present?
        redirect_to @booking, notice: 'Booking declined successfully.'
      else
        redirect_to @booking, alert: 'Booking cannot be declined.'
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

  private

 def booking_conflicts?
    start_time = @booking.start_time
    end_time = @booking.end_time
    psychologist_profile_id = @booking.psychologist_profile_id

    overlapping_bookings = Booking.where(psychologist_profile_id: psychologist_profile_id)
                                 .where.not(id: @booking.id)
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

  # def booking_to_event(booking)
  #   client_name = booking.client_profile&.full_name || 'Unknown Client'
  #   service_name = booking.service&.name || 'Unknown Service'

  #   {
  #     id: booking.id,
  #     title: "#{service_name} with #{client_name}",
  #     start: booking.start_time.iso8601,
  #     end: booking.end_time.iso8601,
  #     color: '#0d6efd',
  #     textColor: 'white',
  #     extendedProps: {
  #       status: booking.status,
  #       client_profile_id: booking.client_profile_id,
  #       internal_client_profile_id: booking.internal_client_profile_id,
  #       service_id: booking.service_id
  #     }
  #   }
  # end
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