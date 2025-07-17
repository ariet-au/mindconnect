class InternalClientProfilesController < ApplicationController
  # Ensure the user is authenticated before any action, if not already handled globally
  # before_action :authenticate_user! # Uncomment if you use Devise or similar for authentication

  before_action :set_internal_client_profile, only: %i[ show edit update destroy ]
  # You might want to add an authorization check here to ensure
  # a psychologist can only manage their own client profiles:
  # before_action :authorize_psychologist_profile, only: %i[ show edit update destroy ]

  # GET /internal_client_profiles or /internal_client_profiles.json
  def index
    if current_user && current_user.psychologist_profile
      @internal_client_profiles = InternalClientProfile.where(
        psychologist_profile_id: current_user.psychologist_profile.id
      ).order(created_at: :desc) # Optional: order by creation date
    else
      @internal_client_profiles = []
      flash[:alert] = "You are not authorized to view this page or your psychologist profile is not set up."
      redirect_to root_path # Or wherever appropriate for unauthorized access
    end
  end

  # GET /internal_client_profiles/1 or /internal_client_profiles/1.json
  def show
  end

  # GET /internal_client_profiles/new
  def new
    @internal_client_profile = InternalClientProfile.new
  end

  # GET /internal_client_profiles/1/edit
  def edit
  end

  # POST /internal_client_profiles or /internal_client_profiles.json
  def create
    @internal_client_profile = InternalClientProfile.new(internal_client_profile_params)
    # Assign the current psychologist's profile to the new internal client profile
    @internal_client_profile.psychologist_profile = current_user.psychologist_profile

    if @internal_client_profile.save
      redirect_to @internal_client_profile, notice: "Profile created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /internal_client_profiles/1 or /internal_client_profiles/1.json
  def update
    respond_to do |format|
      if @internal_client_profile.update(internal_client_profile_params)
        format.html { redirect_to @internal_client_profile, notice: "Internal client profile was successfully updated." }
        format.json { render :show, status: :ok, location: @internal_client_profile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @internal_client_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /internal_client_profiles/1 or /internal_client_profiles/1.json
  def destroy
    @internal_client_profile.destroy!

    respond_to do |format|
      format.html { redirect_to internal_client_profiles_path, status: :see_other, notice: "Internal client profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_internal_client_profile
      # Ensure that the found profile also belongs to the current psychologist
      @internal_client_profile = InternalClientProfile.find(params[:id])
      # Add authorization check here:
      unless @internal_client_profile.psychologist_profile == current_user.psychologist_profile
        flash[:alert] = "You are not authorized to access this client profile."
        redirect_to internal_client_profiles_path # Redirect to their list of clients
      end
    end

    # This method is no longer needed as the assignment is done directly in `create`
    # def assign_psychologist_profile
    #   @internal_client_profile.psychologist_profile_id = current_user.psychologist_profile.id
    # end

    # Only allow a list of trusted parameters through.
    def internal_client_profile_params
      params.require(:internal_client_profile).permit(
        :first_name, :last_name, :phone_number1, :phone_number2, :telegram,
        :whatsapp, :gender, :dob, :country, :city, :address,
        :internal_reference_number, :preferred_contact_method,
        :emergency_contact_name, :emergency_contact_phone, :emergency_contact_relationship,
        :reason_for_referral, :gp_name, :gp_contact_info, :initial_assessment_summary,
        :risk_assessment_summary, :treatment_plan_summary, :first_time_therapy, :status,
        :client_profile_id # Ensure client_profile_id is permitted if it's set via form
      )
    end
end
