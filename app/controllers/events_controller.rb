class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :calendar]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :cancel, :calendar, :attendees]
  before_action :authorize_owner!, only: [:edit, :update, :destroy, :cancel, :attendees]

  def index
    # My events (for the current psychologist)
    if current_user&.psychologist_profile
      @my_events = current_user.psychologist_profile.events.order(start_time: :asc)
    else
      @my_events = []
    end

    # Other events (visible, not hidden or archived, excluding my events)
    @other_events = Event.where(visibility: :visible)
                        .where.not(psychologist_profile_id: current_user&.psychologist_profile&.id)
                        .order(start_time: :asc)
  end

  def show
    @registration = EventRegistration.new(event: @event)
    @registration.build_client_info unless current_user
  end

  def new
    @event = current_user.psychologist_profile.events.new
  end

  def create
    @event = current_user.psychologist_profile.events.new(event_params)
    if @event.save
      redirect_to @event, notice: "Event created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Cancel event and all associated registrations
  def cancel
    ActiveRecord::Base.transaction do
      @event.update!(status: :cancelled)
      @event.event_registrations.update_all(status: :cancelled)
    end
    redirect_to @event, notice: "Event and all registrations have been cancelled."
  rescue => e
    redirect_to @event, alert: "Failed to cancel event: #{e.message}"
  end

  # Safely destroy only if no registrations exist
  def destroy
    if @event.event_registrations.exists?
      redirect_to @event, alert: "You cannot delete an event with existing registrations. Consider cancelling it instead."
    else
      @event.destroy
      redirect_to events_path, notice: "Event deleted successfully."
    end
  end

  # Show list of all attendees for event owner
  def attendees
    @registrations = @event.event_registrations.includes(:client_info)
  end

  def share
    @event = Event.find(params[:id])
    # You can render a share page, or just generate a modal/URL for social sharing
  end

  # Generate downloadable ICS calendar file
  def calendar
    respond_to do |format|
      format.ics do
        cal = Icalendar::Calendar.new
        cal.event do |e|
          e.dtstart     = @event.start_time
          e.dtend       = @event.end_time
          e.summary     = @event.title
          e.description = @event.description
          e.location    = @event.online? ? @event.online_link : @event.address
        end
        cal.publish
        send_data cal.to_ical, type: 'text/calendar', disposition: 'attachment', filename: "#{@event.title.parameterize}.ics"
      end
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_owner!
    unless @event.psychologist_profile.user == current_user
      redirect_to @event, alert: "You’re not authorized to modify this event."
    end
  end

  def event_params
    params.require(:event).permit(
      :title, :description, :start_time, :end_time, :timezone,
      :online, :address, :online_link, :hide_details_until_approved,
      :audience, :access_type, :visibility, :status, :capacity,
      :registration_ends_at, :language, :price, :currency
    )
  end
end
