# app/controllers/psychologist_availabilities_controller.rb
class PsychologistAvailabilitiesController < ApplicationController
  #before_action :authenticate_psychologist!
  before_action :set_psychologist_profile
  before_action :check_psychologist_timezone, only: [:index, :new, :create, :edit, :update, :calendar_blocks]
  before_action :ensure_all_days_available, only: [:index]
  before_action :set_psychologist_availability, only: [:edit, :update, :destroy]

  
  def index
    @availabilities = @psychologist_profile.psychologist_availabilities.order(:day_of_week)
    @new_availability = @psychologist_profile.psychologist_availabilities.build(timezone: @psychologist_profile.timezone)
  end

  def new
    @new_availability = @psychologist_profile.psychologist_availabilities.build(timezone: @psychologist_profile.timezone)
  end

  def create
    @new_availability = @psychologist_profile.psychologist_availabilities.build(psychologist_availability_params)
    @new_availability.timezone = @psychologist_profile.timezone

    if @new_availability.save
      redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availability was successfully created.'
    else
      @availabilities = @psychologist_profile.psychologist_availabilities.order(:day_of_week)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # The timezone is merged here to ensure it's always set from the profile,
    # even if not explicitly sent from the form.
    params_with_timezone = psychologist_availability_params.merge(timezone: @psychologist_profile.timezone)

    if @psychologist_availability.update(params_with_timezone)
      redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availability was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @psychologist_availability.destroy
    redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availability was successfully destroyed.'
  end

  def calendar_blocks
    @psychologist_profile = PsychologistProfile.find(params[:psychologist_profile_id])

    @availabilities = @psychologist_profile.psychologist_availabilities.reject do |avail|
      avail.start_time_of_day.nil? || avail.end_time_of_day.nil?
    end

    respond_to do |format|
      format.json do
        json_payload = @availabilities.map do |a|
          # Convert UTC times from DB to the psychologist's local timezone for display
          local_start = a.start_time_of_day.in_time_zone(@psychologist_profile.timezone)
          local_end = a.end_time_of_day.in_time_zone(@psychologist_profile.timezone)

          {
            daysOfWeek: [a.day_of_week],
            startTime: local_start.strftime("%H:%M"),
            endTime: local_end.strftime("%H:%M")
          }
        end
        render json: json_payload
      end

      # Optional: fallback to avoid HTML render error
      format.html { head :not_found }
    end
  end




  private

  def set_psychologist_profile
    @psychologist_profile = PsychologistProfile.find(params[:psychologist_profile_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Psychologist profile not found."
  end

   def set_psychologist_profile
    @psychologist_profile = PsychologistProfile.find_by(id: params[:psychologist_profile_id])
    unless @psychologist_profile
      redirect_to root_path, alert: "Psychologist profile not found."
      return # Explicitly halt the filter chain if profile is not found
    end
  end

  def check_psychologist_timezone
    unless @psychologist_profile.timezone.present?
      redirect_to edit_psychologist_profile_path(@psychologist_profile),
                  alert: "Please set your timezone in your profile before managing availabilities."
      return # Halts the request
    end
  end

  def ensure_all_days_available
    (0..6).each do |day_of_week|
      unless @psychologist_profile.psychologist_availabilities.exists?(day_of_week: day_of_week)
        @psychologist_profile.psychologist_availabilities.create!(
          day_of_week: day_of_week,
          start_time_of_day: nil,
          end_time_of_day: nil,
          timezone: @psychologist_profile.timezone.presence || Time.zone.name
        )
      end
    end
  end



  # Simplified: Only permit the raw hour and minute parameters.
  # The model will handle combining them into Time objects.
  def psychologist_availability_params
    params.require(:psychologist_availability).permit(
      :day_of_week,
      :start_time_of_day_hour,
      :start_time_of_day_minute,
      :end_time_of_day_hour,
      :end_time_of_day_minute
    )
  end
end
