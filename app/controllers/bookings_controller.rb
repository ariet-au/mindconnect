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
        
        # Initialize booking with default values
        @booking = Booking.new(
            service: @service,
            psychologist_profile: @psychologist_profile,
            status: current_user.psychologist? ? 'confirmed' : 'pending'
        )

        # Determine timezones (priority: browser > psychologist > UTC)
        psych_timezone = @psychologist_profile.timezone || 'UTC'
        browser_timezone = params[:browser_timezone] || session[:browser_timezone]
        @display_timezone = browser_timezone || psych_timezone

        # Initialize slot finder (works in psychologist's timezone)
        slot_finder = TimezoneAwareSlotFinder.new(
            @psychologist_profile.id,
            @service.duration_minutes,
            psych_timezone  # Internal calculations use psychologist's timezone
        )

        # Get default time in psychologist's timezone
        psych_default_time = Time.current.in_time_zone(psych_timezone).beginning_of_hour + 1.hour
        available_slot = slot_finder.next_available_slot(psych_default_time)
        
        # Convert to display timezone
        @default_start_time = if available_slot
                                available_slot.in_time_zone(@display_timezone)
                                else
                                psych_default_time.in_time_zone(@display_timezone)
                                end

        # Set booking times (stored in UTC)
        @booking.start_time = @default_start_time
        @booking.end_time = @default_start_time + @service.duration_minutes.minutes
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
        # 💥 You must set these before rendering :new
        @service = @booking.service
        @psychologist_profile = @service.user.psychologist_profile

        render :new, status: :unprocessable_entity
    end
    end


  def edit
  end

  def update
    if @booking.update(booking_params)
      # Make sure 'notice' is handled in your application layout
      redirect_to @booking, notice: 'Booking was successfully updated.'
    else
      # Important: This will make @booking.errors.any? true in the view
      # and keep the form data filled.
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
      
      :status,
      :notes
    )
  end
end
