class PsychologistAvailabilitiesController < ApplicationController
  before_action :set_psychologist_profile
  before_action :check_psychologist_timezone
  before_action :set_psychologist_availability, only: [:destroy]

  # GET /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities
#  def index
#   @display_timezone = 
#     @psychologist_profile.timezone.presence || params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] 

#   # Load availabilities
#   @availabilities = @psychologist_profile.psychologist_availabilities
#                                          .order(:day_of_week, :start_time_of_day)

#   # Convert each availability's start and end to the display timezone
#   @availabilities_in_display_tz = @availabilities.map do |a|
#     tz = ActiveSupport::TimeZone[@psychologist_profile.timezone] || ActiveSupport::TimeZone['UTC']

#     # Extract the time-of-day from the stored datetime
#     start_local = tz.parse(a.start_time_of_day.strftime("%H:%M"))
#     end_local   = tz.parse(a.end_time_of_day.strftime("%H:%M"))
#     # Convert to display timezone
#     start_in_display = start_local.in_time_zone(@display_timezone)
#     end_in_display   = end_local.in_time_zone(@display_timezone)

#     {
#       id: a.id,
#       day_of_week: a.day_of_week,
#       start_time: start_in_display,
#       end_time: end_in_display
#     }
#   end

#   Rails.logger.debug "Availabilities in display timezone: #{@availabilities_in_display_tz.inspect}"
# end

  def index
    # Load availabilities ordered by day_of_week
    @availabilities = @psychologist_profile.psychologist_availabilities
                                          .order(:day_of_week, :start_time_of_day)

    # Convert times to HH:MM strings to avoid timezone issues
    @availabilities_str = @availabilities.map do |a|
      {
        id: a.id,
        day_of_week: a.day_of_week,
        start_time_of_day: a.start_time_of_day&.strftime('%H:%M'),
        end_time_of_day: a.end_time_of_day&.strftime('%H:%M')
      }
    end
  end



  
  def update_all
    submitted_slots_data = availability_params
    deleted_slot_ids = params[:deleted_slots]&.keys || []   # Grab the IDs of slots marked for deletion
    errors = []

    ActiveRecord::Base.transaction do
      Rails.logger.debug "--- STARTING AVAILABILITIES UPDATE TRANSACTION ---"

      # DELETE slots first
      if deleted_slot_ids.any?
        deleted_slot_ids.each do |id|
          availability = @psychologist_profile.psychologist_availabilities.find_by(id: id)
          if availability
            Rails.logger.debug "Deleting availability ID: #{availability.id}"
            availability.destroy
          else
            Rails.logger.debug "Could not find availability ID #{id} to delete"
          end
        end
      end

      # CREATE/UPDATE slots
      submitted_slots_data.each do |slot_data|
        next if slot_data[:start_time].blank? || slot_data[:end_time].blank?

        is_existing = slot_data[:id].present? && slot_data[:id].to_s.match?(/\A\d+\z/)

        if is_existing
          availability = @psychologist_profile.psychologist_availabilities.find_by(id: slot_data[:id])
          if availability
            availability.assign_attributes(
              day_of_week: slot_data[:day_of_week],
              start_time_of_day: slot_data[:start_time],
              end_time_of_day: slot_data[:end_time],
              timezone: @psychologist_profile.timezone
            )
            errors << "Slot #{availability.id}: #{availability.errors.full_messages.join(', ')}" unless availability.save
          end
        else
          new_availability = @psychologist_profile.psychologist_availabilities.build(
            day_of_week: slot_data[:day_of_week],
            start_time_of_day: slot_data[:start_time],
            end_time_of_day: slot_data[:end_time],
            timezone: @psychologist_profile.timezone
          )
          errors << "Slot: #{new_availability.errors.full_messages.join(', ')}" unless new_availability.save
        end
      end

      raise ActiveRecord::Rollback if errors.present?
    end

    if errors.empty?
      redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availabilities saved successfully.'
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
    tz = @psychologist_profile&.timezone || 'UTC'
    zone = ActiveSupport::TimeZone[tz]

    # Get all availabilities with start/end times
    availabilities = @psychologist_profile.psychologist_availabilities
                                          .where.not(start_time_of_day: nil, end_time_of_day: nil)

    json_data = []

    # Start from the beginning of this week
    start_date = Time.zone.now.beginning_of_week
    end_date = start_date + 8.weeks

    availabilities.each do |a|
      availability_zone = ActiveSupport::TimeZone[a.timezone || tz]

      (start_date.to_date..end_date.to_date).each do |date|
        next unless date.wday == a.day_of_week

        start_dt = availability_zone.local(date.year, date.month, date.day,
                                          a.start_time_of_day.hour, a.start_time_of_day.min)
        end_dt = availability_zone.local(date.year, date.month, date.day,
                                        a.end_time_of_day.hour, a.end_time_of_day.min)

        # --- THIS IS THE FIX ---
        # Send a full ISO 8601 string with the timezone offset.
        # e.g., "2025-08-17T15:00:00+10:00"
        json_data << {
          start: start_dt.iso8601,
          end: end_dt.iso8601,
          display: 'background',
          color: '#008000'
        }
      end
    end

    render json: json_data
  end


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