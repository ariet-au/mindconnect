class EventRegistrationsController < ApplicationController
  before_action :set_event
  before_action :set_registration, only: [:approve, :decline, :cancel, :mark_attended, :mark_no_show]

  # POST /events/:event_id/registrations
  def create
    @registration = @event.event_registrations.new
    @registration.registered_at = Time.current
    @registration.timezone = Time.zone.name
    @registration.user = current_user if current_user

    # Assign existing client_info or build new one
    if registration_params[:client_info_id].present?
      @registration.client_info = ClientInfo.find(registration_params[:client_info_id])
    else
      @registration.build_client_info(client_info_params.merge(
        psychologist_profile_id: @event.psychologist_profile_id,
        submitted_by: current_user&.role == "psychologist" ? "psychologist" : "client",
        status: :event_registered
      ))
    end

    # If event is full, mark as waitlisted
    if @event.capacity.present? && @event.registrations_count >= @event.capacity
      @registration.status = :waitlisted
    else
      @registration.status ||= :pending
    end

    if @registration.save
      redirect_to @event, notice: "Registration submitted successfully!"
    else
      flash.now[:alert] = "Failed to register: #{@registration.errors.full_messages.join(', ')}"
      render "events/show", status: :unprocessable_entity
    end
  end

  # PATCH /events/:event_id/registrations/:id/approve
  def approve
    if @registration.pending? || @registration.waitlisted?
      @registration.update(status: :approved)
      redirect_to @event, notice: "Registration approved."
    end
  end

  def cancel
    if @registration.pending? || @registration.approved? || @registration.waitlisted?
      @registration.update(status: :cancelled)
      promote_waitlisted_registration
      redirect_to @event, notice: "Registration cancelled."
    end
  end

  def decline
    if @registration.pending? || @registration.waitlisted?
      @registration.update(status: :declined)
      promote_waitlisted_registration
      redirect_to @event, notice: "Registration declined."
    end
  end

  # PATCH /events/:event_id/registrations/:id/attended
  def mark_attended
    if @registration.approved?
      @registration.update(status: :attended)
      redirect_to @event, notice: "Marked as attended."
    end
  end

  # PATCH /events/:event_id/registrations/:id/no_show
  def mark_no_show
    if @registration.approved?
      @registration.update(status: :no_show)
      redirect_to @event, notice: "Marked as no-show."
    end
  end

  # PATCH /events/:event_id/cancel_all_registrations
  def cancel_all
    @event.event_registrations.where.not(status: [:cancelled, :declined]).update_all(status: :event_cancelled)
    redirect_to @event, notice: "All registrations marked as event cancelled."
  end

  private

  def promote_waitlisted_registration
    return unless @event.capacity.present?

    # Only promote if there is capacity
    approved_count = @event.event_registrations.where(status: :approved).count
    spots_available = @event.capacity - approved_count
    return if spots_available <= 0

    # Get the first waitlisted registration(s) to promote
    @event.event_registrations.where(status: :waitlisted).order(:created_at).limit(spots_available).each do |reg|
      reg.update(status: :approved)
    end
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_registration
    @registration = @event.event_registrations.find(params[:id])
  end

  # Use these exactly as requested
  def registration_params
    params.require(:event_registration).permit(:status, :price, :currency, :client_info_id)
  end

  def client_info_params
    params.fetch(:event_registration, {})
          .fetch(:client_info_attributes, {})
          .permit(
            :first_name, :last_name, :email, :phone_number, :city, :timezone,
            :year_of_birth, :reason_for_therapy, :lead_source, :referrer_url,
            :landing_page, :referred_by,
            client_contacts_attributes: [:id, :method, :value, :_destroy]
          )
  rescue
    {}
  end
end
