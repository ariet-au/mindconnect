class PsychologistProfilesController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_psychologist_profile, only: %i[ show edit update destroy ]
  before_action :authorize_user!, only: [:edit, :update, :destroy]
  before_action :check_user_confirmation,  only: %i[ edit update destroy ]



  # GET /psychologist_profiles or /psychologist_profiles.json


  def search_landing
    @client_types = ClientType.all
    @issues = Issue.all
    @specialties = Specialty.all
    @countries= PsychologistProfile.where.not(country: [nil, ""]).distinct.order(:country).pluck(:country)
    @cities = PsychologistProfile.where.not(city: [nil, ""]).distinct.order(:city).pluck(:city)
    @genders = PsychologistProfile.where.not(gender: [nil, ""]).distinct.order(:gender).pluck(:gender)
    @languages = Language.all

    client_type_ids = params[:client_type_ids]&.reject(&:blank?) || []

    if client_type_ids.any?
      @issues = Issue.joins(:client_types).where(client_types: { id: client_type_ids }).distinct
    else
      @issues = Issue.all
    end

    
  end

def index
   @psychologist_profiles = PsychologistProfile.verified.order(created_at: :desc)

  if params[:search].present?
    @psychologist_profiles = PsychologistProfile
      .joins(:services) # only if services are part of search
      .merge(PsychologistProfile.search_full_text(params[:search]))
  end

    session[:currency] = params[:currency] if params[:currency].present?

 


  @genders = PsychologistProfile.where.not(gender: [nil, ""]).distinct.order(:gender).pluck(:gender)

  if params[:gender].present?
    @psychologist_profiles = @psychologist_profiles.where(gender: params[:gender])
  end

  # In-person/online filtering
  if params[:in_person] == "1" && params[:online] == "1"
    @psychologist_profiles = @psychologist_profiles.where(in_person: true).or(PsychologistProfile.where(online: true))
  elsif params[:in_person] == "1"
    @psychologist_profiles = @psychologist_profiles.where(in_person: true)
  elsif params[:online] == "1"
    @psychologist_profiles = @psychologist_profiles.where(online: true)
  end

  # Sanitize multi-selects
  specialty_ids    = Array(params[:specialty_ids]).reject(&:blank?)
  issue_ids        = Array(params[:issue_ids]).reject(&:blank?)
  #client_type_ids  = Array(params[:client_type_ids]).reject(&:blank?)
  client_type_ids = if params[:client_type_ids].present?
  Array(params[:client_type_ids]).reject(&:blank?)
  elsif params[:client_type_id].present?
    [params[:client_type_id]]
  else
    []
  end
    language_ids     = Array(params[:language_ids]).reject(&:blank?)

  if language_ids.any?
    @psychologist_profiles = @psychologist_profiles.joins(:languages).where(languages: { id: language_ids }).distinct
  end

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


  # Filter by currency - do this AFTER all ActiveRecord filtering
  target_currency = current_currency.upcase
  min_rate = params[:min_rate].present? ? params[:min_rate].to_f : nil
  max_rate = params[:max_rate].present? ? params[:max_rate].to_f : nil

  # Apply currency filtering only if rate filters are present
  if min_rate.present? || max_rate.present?
    filtered_profiles_array = @psychologist_profiles.filter_map do |profile|
      begin
        # Skip profiles with blank/nil currency or rate
        next if profile.currency.blank? || profile.standard_rate.blank? || profile.standard_rate.to_f <= 0
        
        converted_rate = profile.converted_rate(target_currency)
        next unless converted_rate&.positive? # Skip nil/zero rates
        
        rate_value = converted_rate.to_f
        
        # Check rate bounds
        next unless (min_rate.nil? || rate_value >= min_rate) &&
                    (max_rate.nil? || rate_value <= max_rate)
        
        profile # Return the profile if it passes all criteria
        
      rescue StandardError => e
        Rails.logger.error "Currency conversion failed for profile #{profile.id}: #{e.message}"
        next # Skip this profile and continue
      end
    end
    
    # Convert filtered array to paginated collection
    @psychologist_profiles = Kaminari.paginate_array(filtered_profiles_array).page(params[:page])
  else
    # No currency filtering needed, paginate the ActiveRecord relation directly
    @psychologist_profiles = @psychologist_profiles.page(params[:page])
  end
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
    # Attach and resize image if cropped_blob is present
    if params[:cropped_blob].present?
      @psychologist_profile.profile_image.attach(params[:cropped_blob])
      @psychologist_profile.resize_profile_image
    end

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

  def landing_psych
  end

  def contact_us
  end

  def authorize_user!
    unless @psychologist_profile.user == current_user
      redirect_to root_path, alert: "You are not authorized to edit this profile."
    end
  end


  def cities
    country = params[:country]
    cities = PsychologistProfile.where(country: country)
                              .distinct
                              .pluck(:city)
                              .compact
                              .sort
    render json: cities
  end

  def set
    session[:currency] = params[:currency]
    redirect_back fallback_location: root_path, allow_other_host: false, params: { country: params[:country] }
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_psychologist_profile
      @psychologist_profile = PsychologistProfile.find(params.expect(:id))
    end

    def check_user_confirmation
      if user_signed_in? && !current_user.confirmed?
        flash[:alert] = "Please confirm your email address to continue."
        sign_out current_user
        redirect_to new_user_session_path
      end
    end

     

    # Only allow a list of trusted parameters through.
        def psychologist_profile_params
          params.require(:psychologist_profile).permit(
            :first_name, :last_name, :about_me, :standard_rate, :currency, :years_of_experience, :license_number,
            :country, :city, :address, :telegram, :whatsapp, :contact_phone,
            :contact_phone2, :contact_phone3, :gender, :education, :is_doctor, :in_person, :online, 
            :is_degree_boolean, :profile_img,
            :about_clients, :about_issues, :about_specialties, :primary_contact_method, :timezone,
            issue_ids: [],         # <-- Add this
            client_type_ids: [],  # <-- And this
            specialty_ids: [] ,     # <-- And this,
            language_ids: []
          )
        end


end
