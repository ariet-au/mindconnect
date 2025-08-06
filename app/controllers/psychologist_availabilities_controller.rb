# class PsychologistAvailabilitiesController < ApplicationController
#   before_action :set_psychologist_profile
#   before_action :check_psychologist_timezone
#   before_action :set_psychologist_availability, only: [:destroy]

#   # GET /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities
#   def index
#     @availabilities = @psychologist_profile.psychologist_availabilities.order(:day_of_week, :start_time_of_day)
#     Rails.logger.debug "Loaded availabilities: #{@availabilities.map { |a| { id: a.id, day: a.day_of_week, start: a.start_time_of_day, end: a.end_time_of_day } }}"
#   end

#   # POST /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities
#   def create
#     Rails.logger.debug "Received params: #{params.inspect}"
#     slots = params[:slots]&.values || []
#     Rails.logger.debug "Parsed slots: #{slots.inspect}"
#     errors = []
#     new_availabilities = []

#     ActiveRecord::Base.transaction do
#       slots.each_with_index do |slot, index|
#         Rails.logger.debug "Processing slot ##{index}: #{slot.inspect}"

#         # Skip if both times are blank
#         if slot[:start_time].blank? && slot[:end_time].blank?
#           Rails.logger.debug "Skipping blank slot for day #{slot[:day_of_week]}"
#           next
#         end

#         # Validate day_of_week
#         day_of_week = slot[:day_of_week].to_i
#         unless (0..6).include?(day_of_week)
#           errors << "Slot ##{index}: Invalid day of week: #{day_of_week}"
#           Rails.logger.debug "Invalid day_of_week: #{day_of_week}"
#           next
#         end

#         # Build availability
#         availability = @psychologist_profile.psychologist_availabilities.build(
#           day_of_week: day_of_week,
#           start_time: slot[:start_time],
#           end_time: slot[:end_time],
#           timezone: @psychologist_profile.timezone
#         )

#         if availability.valid?
#           new_availabilities << availability
#           Rails.logger.debug "Slot ##{index} is valid: #{availability.attributes}"
#         else
#           errors << "Slot ##{index}: #{availability.errors.full_messages.join(', ')}"
#           Rails.logger.debug "Validation errors for slot ##{index}: #{availability.errors.full_messages}"
#         end
#       end

#       if errors.any?
#         Rails.logger.debug "Errors found, rolling back: #{errors.join('; ')}"
#         raise ActiveRecord::Rollback
#       else
#         Rails.logger.debug "Clearing existing availabilities"
#         @psychologist_profile.psychologist_availabilities.destroy_all
#         new_availabilities.each do |avail|
#           avail.save!
#           Rails.logger.debug "Saved availability: #{avail.attributes}"
#         end
#       end
#     end

#     if errors.empty?
#       Rails.logger.debug "Save successful, redirecting"
#       redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availabilities saved successfully.'
#     else
#       Rails.logger.debug "Save failed, rendering index with errors: #{errors}"
#       @availabilities = @psychologist_profile.psychologist_availabilities.order(:day_of_week, :start_time_of_day)
#       flash.now[:alert] = errors.join('; ')
#       render :index, status: :unprocessable_entity
#     end
#   end

#   # DELETE /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities/:id
#   def destroy
#     Rails.logger.debug "Destroying availability ID: #{@psychologist_availability.id}"
#     @psychologist_availability.destroy
#     respond_to do |format|
#       format.html { redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availability slot deleted.' }
#       format.json { head :no_content }
#     end
#   end

#   def update
#     # @psychologist_profile is found here
#     if @psychologist_profile.update(psychologist_profile_params)
#       # On success, redirect or respond with a Turbo Stream
#       redirect_to psychologist_profile_path(@psychologist_profile), notice: 'Availability was successfully updated.'
#     else
#       # On failure, re-render the form
#       render :edit, status: :unprocessable_entity
#     end
#   end

#   # GET /psychologist_profiles/:psychologist_profile_id/calendar_blocks.json
#   def calendar_blocks
#     @availabilities = @psychologist_profile.psychologist_availabilities.where.not(start_time_of_day: nil, end_time_of_day: nil)
#     Rails.logger.debug "Calendar blocks: #{@availabilities.map { |a| { day: a.day_of_week, start: a.start_time_of_day, end: a.end_time_of_day } }}"
#     respond_to do |format|
#       format.json do
#         render json: @availabilities.map { |a|
#           {
#             daysOfWeek: [a.day_of_week],
#             startTime: a.start_time_of_day.utc.strftime("%H:%M"),
#             endTime: a.end_time_of_day.utc.strftime("%H:%M")
#           }
#         }
#       end
#       format.html { head :not_found }
#     end
#   end

#   private

#   def set_psychologist_profile
#     @psychologist_profile = PsychologistProfile.find_by(id: params[:psychologist_profile_id])
#     unless @psychologist_profile
#       Rails.logger.debug "Psychologist profile not found: #{params[:psychologist_profile_id]}"
#       redirect_to root_path, alert: 'Psychologist profile not found.'
#     end
#   end

#   def check_psychologist_timezone
#     unless @psychologist_profile.timezone.present?
#       Rails.logger.debug "Timezone missing for profile: #{@psychologist_profile.id}"
#       redirect_to edit_psychologist_profile_path(@psychologist_profile), alert: 'Please set your timezone in your profile.'
#     end
#   end

#   def set_psychologist_availability
#     @psychologist_availability = @psychologist_profile.psychologist_availabilities.find(params[:id])
#   rescue ActiveRecord::RecordNotFound
#     Rails.logger.debug "Availability not found: #{params[:id]}"
#     redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), alert: 'Availability not found.'
#   end
# end

class PsychologistAvailabilitiesController < ApplicationController
  before_action :set_psychologist_profile
  before_action :check_psychologist_timezone
  before_action :set_psychologist_availability, only: [:destroy]

  # GET /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities
  def index
    @availabilities = @psychologist_profile.psychologist_availabilities.order(:day_of_week, :start_time_of_day)
    Rails.logger.debug "Loaded availabilities: #{@availabilities.map { |a| { id: a.id, day: a.day_of_week, start: a.start_time_of_day, end: a.end_time_of_day } }}"
  end

  # POST /psychologist_profiles/:psychologist_profile_id/psychologist_availabilities
  def create
    Rails.logger.debug "Received params: #{params.inspect}"
    slots = params[:slots]&.values || []
    Rails.logger.debug "Parsed slots: #{slots.inspect}"
    errors = []
    new_availabilities = []

    ActiveRecord::Base.transaction do
      slots.each_with_index do |slot, index|
        Rails.logger.debug "Processing slot ##{index}: #{slot.inspect}"

        # Skip if both times are blank. We only want to save filled-in slots.
        if slot[:start_time].blank? && slot[:end_time].blank?
          Rails.logger.debug "Skipping blank slot for day #{slot[:day_of_week]}"
          next
        end

        # Handle the case where only one time is provided.
        if slot[:start_time].blank? || slot[:end_time].blank?
          errors << "Slot ##{index}: Both start and end times must be provided."
          next
        end
        
        # Validate day_of_week
        day_of_week = slot[:day_of_week].to_i
        unless (0..6).include?(day_of_week)
          errors << "Slot ##{index}: Invalid day of week: #{day_of_week}"
          Rails.logger.debug "Invalid day_of_week: #{day_of_week}"
          next
        end
        
        # Build availability with virtual attributes
        availability = @psychologist_profile.psychologist_availabilities.build(
          day_of_week: day_of_week,
          start_time: slot[:start_time],
          end_time: slot[:end_time],
          timezone: @psychologist_profile.timezone
        )

        # Custom server-side validation for start time before end time
        if availability.start_time_of_day && availability.end_time_of_day && availability.end_time_of_day <= availability.start_time_of_day
          errors << "Slot ##{index}: End time must be after start time."
          next
        end

        # Now, check for other model validations
        if availability.valid?
          new_availabilities << availability
          Rails.logger.debug "Slot ##{index} is valid: #{availability.attributes}"
        else
          errors << "Slot ##{index}: #{availability.errors.full_messages.join(', ')}"
          Rails.logger.debug "Validation errors for slot ##{index}: #{availability.errors.full_messages}"
        end
      end

      if errors.any?
        Rails.logger.debug "Errors found, rolling back: #{errors.join('; ')}"
        raise ActiveRecord::Rollback
      else
        Rails.logger.debug "Clearing existing availabilities"
        @psychologist_profile.psychologist_availabilities.destroy_all
        new_availabilities.each do |avail|
          avail.save!
          Rails.logger.debug "Saved availability: #{avail.attributes}"
        end
      end
    end

    if errors.empty?
      Rails.logger.debug "Save successful, redirecting"
      redirect_to psychologist_profile_psychologist_availabilities_path(@psychologist_profile), notice: 'Availabilities saved successfully.'
    else
      Rails.logger.debug "Save failed, rendering index with errors: #{errors}"
      @availabilities = @psychologist_profile.psychologist_availabilities.order(:day_of_week, :start_time_of_day)
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

  def update

    if params[:deleted_slots].present?
      deleted_ids = params[:deleted_slots].keys
      PsychologistAvailability.where(id: deleted_ids, psychologist_profile_id: @psychologist_profile.id).destroy_all
    end
    
    # The rest of your existing update logic can follow here
    # This part handles updating existing slots and creating new ones.
    if params[:slots].present?
      params[:slots].each do |id, slot_data|
        # ... your existing logic to update/create slots
      end
    end
    # @psychologist_profile is found here
    if @psychologist_profile.update(psychologist_profile_params)
      # On success, redirect or respond with a Turbo Stream
      redirect_to psychologist_profile_path(@psychologist_profile), notice: 'Availability was successfully updated.'
    else
      # On failure, re-render the form
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /psychologist_profiles/:psychologist_profile_id/calendar_blocks.json
  def calendar_blocks
    @availabilities = @psychologist_profile.psychologist_availabilities.where.not(start_time_of_day: nil, end_time_of_day: nil)
    Rails.logger.debug "Calendar blocks: #{@availabilities.map { |a| { day: a.day_of_week, start: a.start_time_of_day, end: a.end_time_of_day } }}"
    respond_to do |format|
      format.json do
        render json: @availabilities.map { |a|
          {
            daysOfWeek: [a.day_of_week],
            startTime: a.start_time_of_day.utc.strftime("%H:%M"),
            endTime: a.end_time_of_day.utc.strftime("%H:%M")
          }
        }
      end
      format.html { head :not_found }
    end
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

 
end