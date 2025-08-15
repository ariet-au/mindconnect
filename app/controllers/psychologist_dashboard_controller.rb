class PsychologistDashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_psychologist_role

  def index

  @display_timezone =
      params[:browser_timezone] ||
      session[:browser_timezone] ||
      cookies[:browser_timezone] ||
      @psychologist_profile.timezone.presence ||
      'UTC'

  Time.zone = @display_timezone

    @psychologist = current_user
    @psychologist_profile = @psychologist.psychologist_profile
    if @psychologist_profile
      @upcoming_bookings = Booking.where(psychologist_profile_id: @psychologist_profile.id)
                                  .where('start_time >= ?', Time.current)
                                  .order(start_time: :asc)
                                  .limit(5)
                                  .includes(:internal_client_profile, :client_profile)
      @unavailabilities = PsychologistUnavailability.where(psychologist_profile_id: @psychologist_profile.id)
                                                   .where('end_time >= ?', Time.current)
    else
      Rails.logger.error("No PsychologistProfile found for user ID: #{@psychologist.id}")
      @upcoming_bookings = []
      @unavailabilities = []
    end
  end

  private

  def ensure_psychologist_role
    redirect_to root_path, alert: 'Access denied' unless current_user.psychologist?
  end
end