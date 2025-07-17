# app/controllers/progress_notes_controller.rb
class ProgressNotesController < ApplicationController
  # Ensure the internal client profile is loaded for all actions
  before_action :set_internal_client_profile
  # Ensure the therapy plan is loaded for all actions related to progress notes
  before_action :set_therapy_plan
  # Ensure the specific progress note is loaded for show, edit, update, destroy actions
  before_action :set_progress_note, only: [:show, :edit, :update, :destroy]

  # GET /internal_client_profiles/:internal_client_profile_id/therapy_plans/:therapy_plan_id/progress_notes/new
  def new
    # Build a new progress note associated with the current therapy plan
    @progress_note = @therapy_plan.progress_notes.new
  end

  # POST /internal_client_profiles/:internal_client_profile_id/therapy_plans/:therapy_plan_id/progress_notes
  def create
    # Build a new progress note with permitted parameters
    @progress_note = @therapy_plan.progress_notes.new(progress_note_params)

    if @progress_note.save
      # Redirect to the show page of the newly created progress note
      redirect_to [@internal_client_profile, @therapy_plan, @progress_note], notice: "Progress note was successfully created."
    else
      # Re-render the new form if saving fails (to display errors)
      render :new, status: :unprocessable_entity
    end
  end

  # GET /internal_client_profiles/:internal_client_profile_id/therapy_plans/:therapy_plan_id/progress_notes/:id
  def show
    # @progress_note is already set by the before_action
  end

  # GET /internal_client_profiles/:internal_client_profile_id/therapy_plans/:therapy_plan_id/progress_notes/:id/edit
  def edit
    # @progress_note is already set by the before_action
  end

  # PATCH/PUT /internal_client_profiles/:internal_client_profile_id/therapy_plans/:therapy_plan_id/progress_notes/:id
  def update
    if @progress_note.update(progress_note_params)
      # Redirect to the show page after successful update
      redirect_to [@internal_client_profile, @therapy_plan, @progress_note], notice: "Progress note was successfully updated."
    else
      # Re-render the edit form if updating fails
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /internal_client_profiles/:internal_client_profile_id/therapy_plans/:therapy_plan_id/progress_notes/:id
  def destroy
    @progress_note.destroy
    # Simplify to only redirect for HTML requests.
    # Turbo will intercept this redirect and, combined with data-turbo-reload="true",
    # will trigger a full page reload.
    redirect_to internal_client_profile_therapy_plan_path(@internal_client_profile, @therapy_plan), notice: "Progress note was successfully deleted."
    # No 'return' needed immediately after redirect_to if it's the last line in the action
    # and no implicit render would occur. However, adding it is good practice for clarity.
  end


  private

  # Sets the @internal_client_profile instance variable based on the :internal_client_profile_id parameter
  def set_internal_client_profile
    @internal_client_profile = InternalClientProfile.find(params[:internal_client_profile_id])
  end

  # Sets the @therapy_plan instance variable based on the :therapy_plan_id parameter
  # It's nested under @internal_client_profile to ensure correct association
  def set_therapy_plan
    @therapy_plan = @internal_client_profile.therapy_plans.find(params[:therapy_plan_id])
  end

  # Sets the @progress_note instance variable based on the :id parameter
  # It's nested under @therapy_plan to ensure correct association
  def set_progress_note
    @progress_note = @therapy_plan.progress_notes.find(params[:id])
  end

  # Defines the strong parameters for progress notes to prevent mass assignment vulnerabilities
  def progress_note_params
    params.require(:progress_note).permit(:note_date, :notes, :homework_assigned, :assessment_score, :booking_id)
  end
end
