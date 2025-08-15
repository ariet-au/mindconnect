class PsychologistAvailabilitiesController < ApplicationController
  before_action :set_psychologist_profile
  before_action :check_psychologist_timezone
  before_action :set_psychologist_availability, only: [:destroy]

  # GET /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities
 def index
  @display_timezone = 
    params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] || @psychologist_profile.timezone.presence ||'UTC'

  # Load availabilities
  @availabilities = @psychologist_profile.psychologist_availabilities
                                         .order(:day_of_week, :start_time_of_day)

  # Convert each availability's start and end to the display timezone
  @availabilities_in_display_tz = @availabilities.map do |a|
    tz = ActiveSupport::TimeZone[@psychologist_profile.timezone] || ActiveSupport::TimeZone['UTC']

    # Extract the time-of-day from the stored datetime
    start_local = tz.parse(a.start_time_of_day.strftime("%H:%M"))
    end_local   = tz.parse(a.end_time_of_day.strftime("%H:%M"))
    # Convert to display timezone
    start_in_display = start_local.in_time_zone(@display_timezone)
    end_in_display   = end_local.in_time_zone(@display_timezone)

    {
      id: a.id,
      day_of_week: a.day_of_week,
      start_time: start_in_display,
      end_time: end_in_display
    }
  end

  Rails.logger.debug "Availabilities in display timezone: #{@availabilities_in_display_tz.inspect}"
end


  def update_all
  submitted_slots_data = availability_params
  errors = []

  ActiveRecord::Base.transaction do
    Rails.logger.debug "--- STARTING AVAILABILITIES UPDATE TRANSACTION ---"

    submitted_slots_data.each do |slot_data|
      Rails.logger.debug "Processing slot_data: #{slot_data.inspect}"

      # Skip blank slots
      next if slot_data[:start_time].blank? || slot_data[:end_time].blank?

      # Find an existing record by ID or build a new one.
      # The key check: Is the ID a numeric string?
      is_existing = slot_data[:id].present? && slot_data[:id].to_s.match?(/\A\d+\z/)
      Rails.logger.debug "Is existing slot? #{is_existing}"

      if is_existing
        # Logic for existing records
        availability = @psychologist_profile.psychologist_availabilities.find_by(id: slot_data[:id])
        if availability
          Rails.logger.debug "Found existing availability with ID: #{availability.id}"
          availability.assign_attributes(
            day_of_week: slot_data[:day_of_week],
            start_time_of_day: slot_data[:start_time],
            end_time_of_day: slot_data[:end_time],
            timezone: @psychologist_profile.timezone
          )
          unless availability.save
            errors << "Slot: #{availability.errors.full_messages.join(', ')}"
            Rails.logger.debug "Failed to save existing slot. Errors: #{availability.errors.full_messages}"
          else
            Rails.logger.debug "Successfully updated existing slot ID: #{availability.id}"
          end
        else
          errors << "Slot with ID #{slot_data[:id]} not found."
          Rails.logger.debug "ERROR: Existing slot with ID #{slot_data[:id]} not found."
        end
      else
        # This is the crucial logic for NEW records that was previously failing
        Rails.logger.debug "Building NEW availability record."
        new_availability = @psychologist_profile.psychologist_availabilities.build(
          day_of_week: slot_data[:day_of_week],
          start_time_of_day: slot_data[:start_time],
          end_time_of_day: slot_data[:end_time],
          timezone: @psychologist_profile.timezone
        )
        unless new_availability.save
          errors << "Slot: #{new_availability.errors.full_messages.join(', ')}"
          Rails.logger.debug "Failed to save new slot. Errors: #{new_availability.errors.full_messages}"
        else
          Rails.logger.debug "Successfully saved NEW slot with ID: #{new_availability.id}"
        end
      end
    end

    if errors.present?
      Rails.logger.debug "Errors found, rolling back transaction: #{errors.join('; ')}"
      raise ActiveRecord::Rollback
    else
      Rails.logger.debug "No errors. Committing transaction."
    end
  end

  # The rest of your redirect and render logic is unchanged
  if errors.empty?
    redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile),
                notice: 'Availabilities saved successfully.'
  else
    @availabilities = @psychologist_profile.psychologist_availabilities.order(:day_of_week, :start_time_of_day)
    flash.now[:alert] = errors.join('; ')
    render :index, status: :unprocessable_entity
  end
end

  def destroy
    Rails.logger.debug "Destroying availability ID: #{@psychologist_availability.id}"
    @psychologist_availability.destroy
    respond_to do |format|
      format.html { redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availability slot deleted.' }
      format.json { head :no_content }
    end
  end

  def calendar_blocks
    # Determine viewer/browser timezone
    display_timezone = params[:tz].presence || 'UTC'

    # Load all availabilities with start and end times
    @availabilities = @psychologist_profile.psychologist_availabilities
                                          .where.not(start_time_of_day: nil, end_time_of_day: nil)

    respond_to do |format|
      format.json do
        json_data = @availabilities.map do |a|
          # Use availability timezone, fallback to psychologist, fallback to UTC
          availability_tz = a.timezone.presence || @psychologist_profile.timezone.presence || 'UTC'
          tz = ActiveSupport::TimeZone[availability_tz]

          # Parse stored time-of-day in availability's timezone
          start_local = tz.parse(a.start_time_of_day.strftime("%H:%M"))
          end_local   = tz.parse(a.end_time_of_day.strftime("%H:%M"))

          # Convert to viewer's timezone
          start_in_display = start_local.in_time_zone(display_timezone)
          end_in_display   = end_local.in_time_zone(display_timezone)

          {
            daysOfWeek: [a.day_of_week],
            startTime: start_in_display.strftime("%H:%M:%S"),
            endTime: end_in_display.strftime("%H:%M:%S"),
            timezone: display_timezone
          }
        end

        render json: json_data
      end

      format.html { head :not_found }
    end
  end



  # def calendar_blocks
  #   @availabilities = @psychologist_profile.psychologist_availabilities.where.not(start_time_of_day: nil, end_time_of_day: nil)
  #   respond_to do |format|
  #     format.json do
  #       json_data = @availabilities.map do |a|
  #         {
  #           daysOfWeek: [a.day_of_week],
  #           startTime: a.start_time_of_day.strftime("%H:%M:%S"),
  #           endTime: a.end_time_of_day.strftime("%H:%M:%S"),
  #           timezone: a.timezone
  #         }
  #       end
  #       render json: json_data
  #     end
  #     format.html { head :not_found }
  #   end
  # end

  private

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
  
  def availability_params
    params.fetch(:slots, {}).values.map do |slot|
      slot.permit(:id, :day_of_week, :start_time, :end_time)
    end
  end
end