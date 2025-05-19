class PsychologistProfilesController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_psychologist_profile, only: %i[ show edit update destroy ]
  before_action :authorize_user!, only: [:edit, :update, :destroy]



  # GET /psychologist_profiles or /psychologist_profiles.json


  def search_landing
    @client_types = ClientType.all
    @issues = Issue.all
    @specialties = Specialty.all
    @countries= PsychologistProfile.where.not(country: [nil, ""]).distinct.order(:country).pluck(:country)
    @cities = PsychologistProfile.where.not(city: [nil, ""]).distinct.order(:city).pluck(:city)
    
  end

def index
  @psychologist_profiles = PsychologistProfile.includes(:user).all

  if params[:gender].present?
    @psychologist_profiles = @psychologist_profiles.where(gender: params[:gender])
  end


  if params[:delivery_methods].present?
    methods = Array(params[:delivery_methods]).reject(&:blank?)

    if methods.any?
      method_values = methods.map { |m| Service.delivery_methods[m] }

      @psychologist_profiles = @psychologist_profiles
        .left_outer_joins(user: :services)
        .where(
          'services.delivery_method IN (?) OR services.id IS NULL',
          method_values
        )
        .distinct
    end
  end

  # Sanitize multi-selects
  specialty_ids    = Array(params[:specialty_ids]).reject(&:blank?)
  issue_ids        = Array(params[:issue_ids]).reject(&:blank?)
  client_type_ids  = Array(params[:client_type_ids]).reject(&:blank?)

  if specialty_ids.any?
    @psychologist_profiles = @psychologist_profiles.joins(:specialties).where(specialties: { id: specialty_ids }).distinct
  end

  if issue_ids.any?
    @psychologist_profiles = @psychologist_profiles.joins(:issues).where(issues: { id: issue_ids }).distinct
  end

  if client_type_ids.any?
    @psychologist_profiles = @psychologist_profiles.joins(:client_types).where(client_types: { id: client_type_ids }).distinct
  end

  if params[:country].present?
    @psychologist_profiles = @psychologist_profiles.where(country: params[:country])
  end

  if params[:city].present?
    @psychologist_profiles = @psychologist_profiles.where("city ILIKE ?", "%#{params[:city]}%")
  end

  if params[:keywords].present?
    @psychologist_profiles = @psychologist_profiles.where("title ILIKE ?", "%#{params[:keywords]}%")
  end

  # Add pagination if using kaminari or pagy
  @psychologist_profiles = @psychologist_profiles.page(params[:page])
end



  # GET /psychologist_profiles/1 or /psychologist_profiles/1.json
  def show
  end

  # GET /psychologist_profiles/new
  def new
    @psychologist_profile = PsychologistProfile.new
  end

  # GET /psychologist_profiles/1/edit
  def edit
  end

  # POST /psychologist_profiles or /psychologist_profiles.json
  def create
    @psychologist_profile = PsychologistProfile.new(psychologist_profile_params)
    @psychologist_profile.user_id = current_user.id 
    
    respond_to do |format|
      if @psychologist_profile.save
        format.html { redirect_to @psychologist_profile, notice: "Psychologist profile was successfully created." }
        format.json { render :show, status: :created, location: @psychologist_profile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @psychologist_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /psychologist_profiles/1 or /psychologist_profiles/1.json
  def update
    respond_to do |format|
      if @psychologist_profile.update(psychologist_profile_params)
        format.html { redirect_to @psychologist_profile, notice: "Psychologist profile was successfully updated." }
        format.json { render :show, status: :ok, location: @psychologist_profile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @psychologist_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /psychologist_profiles/1 or /psychologist_profiles/1.json
  def destroy
    @psychologist_profile.destroy!

    respond_to do |format|
      format.html { redirect_to psychologist_profiles_path, status: :see_other, notice: "Psychologist profile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def authorize_user!
    unless @psychologist_profile.user == current_user
      redirect_to root_path, alert: "You are not authorized to edit this profile."
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_psychologist_profile
      @psychologist_profile = PsychologistProfile.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
        def psychologist_profile_params
          params.require(:psychologist_profile).permit(
            :first_name, :last_name, :about_me, :standard_rate, :currency, :years_of_experience, :license_number,
            :country, :city, :address, :telegram, :whatsapp, :contact_phone,
            :contact_phone2, :contact_phone3, :gender, :education, :is_doctor,
            :is_degree_boolean, :profile_img,
            issue_ids: [],         # <-- Add this
            client_type_ids: [],  # <-- And this
            specialty_ids: []      # <-- And this
          )
        end


end
