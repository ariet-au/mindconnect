# app/controllers/psychologist_unavailabilities_controller.rb
class PsychologistUnavailabilitiesController < ApplicationController
  before_action :set_psychologist_profile

  def calendar
    # Just render calendar view
    @psychologist_profile = current_user.psychologist_profile
    
  end

  def index
    @unavailabilities = @psychologist_profile.psychologist_unavailabilities
    
    render json: @unavailabilities.map { |u|
      {
        id: u.id,
        title: u.reason || 'Unavailable',
        start: u.start_time.iso8601,
        end: u.end_time.iso8601,
        color: '#d9534f' # Bootstrap danger red
      }
    }
  end

  def create
    @unavailability = @psychologist_profile.psychologist_unavailabilities.new(unavailability_params)
    if @unavailability.save
      head :ok
    else
      render json: @unavailability.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @unavailability = @psychologist_profile.psychologist_unavailabilities.find(params[:id])
    @unavailability.destroy
    head :no_content
  end

  private

  def set_psychologist_profile
    @psychologist_profile = current_user.psychologist_profile
  end

  def unavailability_params
    params.require(:psychologist_unavailability).permit(:start_time, :end_time, :reason, :recurring, :day_of_week, :timezone)
  end
end
