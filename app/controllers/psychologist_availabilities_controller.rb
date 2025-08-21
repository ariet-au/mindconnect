class PsychologistAvailabilitiesController < ApplicationController
  before_action :set_psychologist_profile
  before_action :check_psychologist_timezone
  before_action :set_psychologist_availability, only: [:destroy]



def index
  # Load availabilities ordered by day_of_week
  @availabilities = @psychologist_profile.psychologist_availabilities
                                        .order(:day_of_week, :start_time_of_day)
end


  def update_all
    submitted_slots_data = availability_params
    deleted_slot_ids = params[:deleted_slots]&.keys || []
    errors = []
    tz = @psychologist_profile.timezone.presence || 'UTC'
    
    ActiveRecord::Base.transaction do
      # DELETE slots - more efficient bulk deletion
      if deleted_slot_ids.any?
        @psychologist_profile.psychologist_availabilities
                            .where(id: deleted_slot_ids)
                            .destroy_all
      end
      
      # CREATE / UPDATE slots
      submitted_slots_data.each do |slot_data|
        next if slot_data[:start_time].blank? || slot_data[:end_time].blank?
        
        begin
          # Parse only for validation, don't convert
          start_parsed = Time.parse(slot_data[:start_time])
          end_parsed = Time.parse(slot_data[:end_time])
          
          # Validate time range
          if start_parsed >= end_parsed
            errors << "Start time must be before end time"
            next
          end
          
          is_existing = slot_data[:id].present? && slot_data[:id].to_s.match?(/\A\d+\z/)
          
          if is_existing
            availability = @psychologist_profile.psychologist_availabilities.find_by(id: slot_data[:id])
            if availability
              availability.assign_attributes(
                day_of_week: slot_data[:day_of_week],
                start_time_of_day: slot_data[:start_time],
                end_time_of_day: slot_data[:end_time],
                timezone: tz
              )
              unless availability.save
                errors << "Slot #{availability.id}: #{availability.errors.full_messages.join(', ')}"
              end
            else
              errors << "Slot with ID #{slot_data[:id]} not found"
            end
          else
            new_availability = @psychologist_profile.psychologist_availabilities.build(
              day_of_week: slot_data[:day_of_week],
              start_time_of_day: slot_data[:start_time],
              end_time_of_day: slot_data[:end_time],
              timezone: tz
            )
            unless new_availability.save
              errors << "New slot: #{new_availability.errors.full_messages.join(', ')}"
            end
          end
          
        rescue ArgumentError => e
          errors << "Invalid time format: #{e.message}"
        end
      end
      
      # Rollback transaction if there are any errors
      raise ActiveRecord::Rollback if errors.any?
    end
  
  # Return success/failure with errors
  if errors.any?
    redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), alert: "Availability could not be saved: #{errors.join(', ')}"
  else
    redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availability successfully saved!'
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
  tz = @psychologist_profile.timezone || params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone]  || 'UTC'


  zone = ActiveSupport::TimeZone[tz]

  availabilities = @psychologist_profile.psychologist_availabilities
                                       .where.not(start_time_of_day: nil, end_time_of_day: nil)

  json_data = []
  start_date = Time.zone.now.beginning_of_week
  end_date   = start_date + 8.weeks

  availabilities.each do |a|
    availability_zone = ActiveSupport::TimeZone[a.timezone || tz]

    (start_date.to_date..end_date.to_date).each do |date|
      next unless date.wday == a.day_of_week

      # Treat stored hour/minute as local to psychologist
      start_dt = availability_zone.local(date.year, date.month, date.day,
                                         a.start_time_of_day.hour,
                                         a.start_time_of_day.min)
      end_dt   = availability_zone.local(date.year, date.month, date.day,
                                         a.end_time_of_day.hour,
                                         a.end_time_of_day.min)

      json_data << {
        # CORRECTED: Convert to UTC before creating the ISO8601 string
        start: start_dt.iso8601,
        end:   end_dt.iso8601,
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