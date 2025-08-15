# This controller handles the management of a psychologist's availability slots.
# It is designed to work with time strings directly, without performing any timezone conversions.
class PsychologistAvailabilitiesController < ApplicationController
  before_action :set_psychologist_profile
  before_action :check_psychologist_timezone
  before_action :set_psychologist_availability, only: [:destroy]

  # GET /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities
  def index
    # The timezone of the viewer (the client's browser). This is currently unused
    # in the view logic but is kept here for potential future use.
    @viewer_timezone = params[:tz] || 'UTC'

    # Retrieve all availabilities for the psychologist. No records are filtered out here.
    @availabilities = @psychologist_profile.psychologist_availabilities
                                           .order(:day_of_week, :start_time_of_day)

    # Added debug log to inspect the loaded availabilities
    Rails.logger.debug "Availabilities loaded: #{@availabilities.inspect}"
  end

  # This action is no longer used, as we're now handling all form submissions with a single
  # `update_all` action.
  def create
    head :not_found
  end

  # This action is also no longer used. `update_all` now handles all form submissions,
  # including creation, deletion, and updates.
  def update
    head :not_found
  end

  # PATCH /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities/update_all
  # This action is a robust single endpoint to handle creating, updating, and deleting
  # all availability slots from the form.
  def update_all
    # IMPORTANT: We now use the new `availability_params` method to get only permitted data.
    submitted_slots = availability_params[:slots]&.values || []
    deleted_slot_ids = params[:deleted_slots]&.keys || []
    errors = []
    
    # Use a transaction to ensure all database operations succeed or fail together.
    ActiveRecord::Base.transaction do
      # Process all submitted slots from the form, creating or updating records
      submitted_slots.each_with_index do |slot, index|
        # Skip blank slots to avoid creating empty records
        next if slot[:start_time].blank? && slot[:end_time].blank?

        # Find the existing record by ID or build a new one
        availability = if slot[:id].present?
                         @psychologist_profile.psychologist_availabilities.find_by(id: slot[:id])
                       else
                         @psychologist_profile.psychologist_availabilities.build
                       end
        
        # If the record is new or found, update its attributes
        if availability
          # The model now handles parsing the time strings
          availability.assign_attributes(
            day_of_week: slot[:day_of_week],
            start_time_of_day: slot[:start_time],
            end_time_of_day: slot[:end_time]
          )
          
          unless availability.save
            errors << "Slot ##{index}: #{availability.errors.full_messages.join(', ')}"
          end
        else
          errors << "Slot ##{index}: Availability not found for ID: #{slot[:id]}"
        end
      end
      
      # Destroy the slots that were explicitly marked for deletion
      if deleted_slot_ids.present?
        @psychologist_profile.psychologist_availabilities.where(id: deleted_slot_ids).destroy_all
      end

      # If any errors were found during the process, roll back the entire transaction
      if errors.present?
        Rails.logger.debug "Errors found, rolling back: #{errors.join('; ')}"
        raise ActiveRecord::Rollback
      end
    end

    if errors.empty?
      redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile),
                  notice: 'Availabilities saved successfully.'
    else
      @availabilities = @psychologist_profile.psychologist_availabilities
                                             .where.not(start_time_of_day: nil, end_time_of_day: nil)
                                             .order(:day_of_week, :start_time_of_day)
      flash.now[:alert] = errors.join('; ')
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities/:id
  def destroy
    Rails.logger.debug "Destroying availability ID: #{@psychologist_availability.id}"
    @psychologist_availability.destroy
    respond_to do |format|
      format.html { redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availability slot deleted.' }
      format.json { head :no_content }
    end
  end

  # GET /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities/calendar_blocks.json
  # This is a public endpoint used to retrieve availability data for a calendar view.
  def calendar_blocks
    @availabilities = @psychologist_profile.psychologist_availabilities.where.not(start_time_of_day: nil, end_time_of_day: nil)

    respond_to do |format|
      format.json do
        json_data = @availabilities.map do |a|
          {
            daysOfWeek: [a.day_of_week],
            startTime: a.start_time_of_day.strftime("%H:%M:%S"),
            endTime: a.end_time_of_day.strftime("%H:%M:%S"),
            timezone: a.timezone
          }
        end

        render json: json_data
      end
      format.html { head :not_found }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_psychologist_profile
    @psychologist_profile = PsychologistProfile.find_by(id: params[:psychologist_profile_id])
    unless @psychologist_profile
      Rails.logger.debug "Psychologist profile not found: #{params[:psychologist_profile_id]}"
      redirect_to root_path, alert: 'Psychologist profile not found.'
    end
  end

  def check_psychologist_timezone
    unless @psychologist_profile.timezone.present?
      Rails.logger.debug "Timezone missing for profile: #{@psychologist_profile.id}"
      redirect_to edit_psychologist_profile_path(@psychologist_profile), alert: 'Please set your timezone in your profile.'
    end
  end

  def set_psychologist_availability
    @psychologist_availability = @psychologist_profile.psychologist_availabilities.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.debug "Availability not found: #{params[:id]}"
    redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), alert: 'Availability not found.'
  end
  
  # A private method that defines the permitted parameters for a single availability slot.
  # This is crucial for preventing mass assignment vulnerabilities.
  def availability_params
    params.permit(slots: [:id, :day_of_week, :start_time, :end_time])
  end
end
