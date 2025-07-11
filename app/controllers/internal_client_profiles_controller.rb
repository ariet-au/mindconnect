class InternalClientProfilesController < ApplicationController
  before_action :set_internal_client_profile, only: %i[ show edit update destroy ]

  # GET /internal_client_profiles or /internal_client_profiles.json
  def index
    @internal_client_profiles = InternalClientProfile.all
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
      @internal_client_profile = InternalClientProfile.find(params.expect(:id))
    end
    def assign_psychologist_profile
      @internal_client_profile.psychologist_profile_id = current_user.psychologist_profile.id
    end

    # Only allow a list of trusted parameters through.
    def internal_client_profile_params
      params.expect(internal_client_profile: [ :first_name,
       :last_name, :phone_number1, :phone_number2, :telegram, 
       :whatsapp, :gender, :dob, :country, :city, :address,
        :internal_reference_number, :preferred_contact_method, 
        :emergency_contact_name, :emergency_contact_phone, :emergency_contact_relationship,
         :reason_for_referral, :gp_name, :gp_contact_info, :initial_assessment_summary,
          :risk_assessment_summary, :treatment_plan_summary, :first_time_therapy, :status, 
           :client_profile_id ])
    end
end
