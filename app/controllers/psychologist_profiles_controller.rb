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
    @religions = PsychologistProfile.where.not(religion: [nil, ""]).distinct.order(:religion).pluck(:religion)
    @languages = Language.all

    client_type_ids = params[:client_type_ids]&.reject(&:blank?) || []

    if client_type_ids.any?
      @issues = Issue.joins(:client_types).where(client_types: { id: client_type_ids }).distinct
    else
      @issues = Issue.all
    end

    
  end

  def index
    # --- Setup for Country/City Filtering ---
    @countries_with_cities = get_countries_with_cities_data
    @cities_for_select = []
    if params[:country].present?
      selected_country_data = @countries_with_cities.find { |c| c['name'] == params[:country] }
      @cities_for_select = selected_country_data['cities'] if selected_country_data
    end
    # --- End of Setup ---

    #@psychologist_profiles = PsychologistProfile.order(updated_at: :desc)
    @psychologist_profiles = PsychologistProfile.confirmed.filled.active.order(updated_at: :desc)
    # if params[:search].present?
    #   @psychologist_profiles = @psychologist_profiles
    #   .merge(PsychologistProfile.search_full_text(params[:search]))
    # end

    if params[:search].present?
      search_term = params[:search].strip.downcase
      @psychologist_profiles = @psychologist_profiles
        .merge(PsychologistProfile.search_full_text(search_term))
    end

    session[:currency] = params[:currency] if params[:currency].present?

    @genders = PsychologistProfile.where.not(gender: [nil, ""]).distinct.order(:gender).pluck(:gender)
    @religions = PsychologistProfile.where.not(religion: [nil, ""]).distinct.order(:religion).pluck(:religion)

    if params[:religion].present?
      @psychologist_profiles = @psychologist_profiles.where(religion: params[:religion])
    end

    if params[:gender].present?
      @psychologist_profiles = @psychologist_profiles.where(gender: params[:gender])
    end

    # In-person/online filtering
    if params[:in_person] == "1" && params[:online] == "1"
      @psychologist_profiles = @psychologist_profiles.where("in_person = ? OR online = ?", true, true)
    elsif params[:in_person] == "1"
      @psychologist_profiles = @psychologist_profiles.where(in_person: true)
    elsif params[:online] == "1"
      @psychologist_profiles = @psychologist_profiles.where(online: true)
    end


    # Sanitize multi-selects
    specialty_ids = Array(params[:specialty_ids]).reject(&:blank?)
    issue_ids = Array(params[:issue_ids]).reject(&:blank?)
    client_type_ids = if params[:client_type_ids].present?
      Array(params[:client_type_ids]).reject(&:blank?)
    elsif params[:client_type_id].present?
      [params[:client_type_id]]
    else
      []
    end
    language_ids = Array(params[:language_ids]).reject(&:blank?)

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
      
      @psychologist_profiles = @psychologist_profiles.verified.distinct

      # Convert filtered array to paginated collection
      @psychologist_profiles = Kaminari.paginate_array(filtered_profiles_array).page(params[:page])
    else
      # No currency filtering needed, paginate the ActiveRecord relation directly
      @psychologist_profiles = @psychologist_profiles.page(params[:page])
    end
  end




  # GET /psychologist_profiles/1 or /psychologist_profiles/1.json
  def show
    @psychologist_profile = PsychologistProfile.find(params[:id])

    # Debug each source of timezone
    Rails.logger.info "[TIMEZONE DEBUG] params[:browser_timezone]: #{params[:browser_timezone].inspect}"
    Rails.logger.info "[TIMEZONE DEBUG] session[:browser_timezone]: #{session[:browser_timezone].inspect}"
    Rails.logger.info "[TIMEZONE DEBUG] cookies[:browser_timezone]: #{cookies[:browser_timezone].inspect}"
    Rails.logger.info "[TIMEZONE DEBUG] profile timezone: #{@psychologist_profile.timezone.inspect}"

    # Determine display timezone (similar to your booking controller)
    @display_timezone =
      params[:browser_timezone] ||
      session[:browser_timezone] ||
      cookies[:browser_timezone] ||
      @psychologist_profile.timezone.presence ||
      'UTC'
    Time.zone = @display_timezone

    Rails.logger.info "[TIMEZONE DEBUG] Chosen display timezone: #{@display_timezone.inspect}"

    # Get next available slot
    next_slot_utc = @psychologist_profile.next_available_slot
    Rails.logger.info "[TIMEZONE DEBUG] Next available slot (UTC): #{next_slot_utc.inspect}"

    @next_available_slot = next_slot_utc&.in_time_zone(@display_timezone)
    Rails.logger.info "[TIMEZONE DEBUG] Next available slot (in display timezone): #{@next_available_slot.inspect}"

    # For timezone conversion in JavaScript
    if @display_timezone
      @display_timezone_offset_seconds = ActiveSupport::TimeZone.new(@display_timezone).utc_offset
      Rails.logger.info "[TIMEZONE DEBUG] Offset seconds for #{@display_timezone}: #{@display_timezone_offset_seconds}"
    else
      Rails.logger.warn "[TIMEZONE DEBUG] No display timezone set, skipping offset calculation"
    end
  end



  def show_mob
    @psychologist_profile = PsychologistProfile.find(params[:id])
  
    # Determine display timezone (similar to your booking controller)
    @display_timezone = params[:browser_timezone] || session[:browser_timezone] || cookies[:browser_timezone] || @psychologist_profile.timezone.presence || 'UTC'
    Rails.logger.info "[TIMEZONE DEBUG] Display timezone set to: #{@display_timezone.inspect}"
    Time.zone = @display_timezone
    # Get next available slot
    next_slot_utc = @psychologist_profile.next_available_slot
    

    @next_available_slot = next_slot_utc&.in_time_zone(@display_timezone)
    
    # For timezone conversion in JavaScript
    @display_timezone_offset_seconds = ActiveSupport::TimeZone.new(@display_timezone).utc_offset if @display_timezone
  end

def show_mob2
  @psychologist_profile = PsychologistProfile.find(params[:id])

  # Determine display timezone (similar to your booking controller)
  @display_timezone =
    params[:browser_timezone] ||
    session[:browser_timezone] ||
    cookies[:browser_timezone] ||
    @psychologist_profile.timezone.presence ||
    'UTC'

  Time.zone = @display_timezone
  next_slot_utc = @psychologist_profile.next_available_slot
  @next_available_slot = next_slot_utc&.in_time_zone(@display_timezone)
  # For timezone conversion in JavaScript
  if @display_timezone
    @display_timezone_offset_seconds = ActiveSupport::TimeZone.new(@display_timezone).utc_offset
  else
    Rails.logger.warn "[TIMEZONE DEBUG] No display timezone set, skipping offset calculation"
  end
end

def show_mob3
  @psychologist_profile = PsychologistProfile.find(params[:id])

  # Determine display timezone (similar to your booking controller)
  @display_timezone =
    params[:browser_timezone] ||
    session[:browser_timezone] ||
    cookies[:browser_timezone] ||
    @psychologist_profile.timezone.presence ||
    'UTC'

  Time.zone = @display_timezone
  next_slot_utc = @psychologist_profile.next_available_slot
  @next_available_slot = next_slot_utc&.in_time_zone(@display_timezone)
  # For timezone conversion in JavaScript
  if @display_timezone
    @display_timezone_offset_seconds = ActiveSupport::TimeZone.new(@display_timezone).utc_offset
  else
    Rails.logger.warn "[TIMEZONE DEBUG] No display timezone set, skipping offset calculation"
  end
end

  # GET /psychologist_profiles/new
  def new
    @psychologist_profile = PsychologistProfile.new
    @psychologist_profile.educations.build
  end

  # GET /psychologist_profiles/1/edit
  def edit
    @psychologist_profile = PsychologistProfile.find(params[:id])
    # Ensure there's at least one blank education form for adding new ones
    # or if the profile somehow has no existing educations
    @psychologist_profile.educations.build if @psychologist_profile.educations.empty?
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


  def filter_cities
    country = params[:country]
    cities = PsychologistProfile.where(country: country)
                              .distinct
                              .pluck(:city)
                              .compact
                              .sort
    render json: cities
  end


  def cities
    # Load the master list of locations from the YAML file
    locations = YAML.load_file(Rails.root.join('config', 'countries_cities.yml'))
    
    # Find the cities for the selected country, or return an empty array if the country isn't found
    country_name = params[:country]
    cities = locations[country_name] || []
    
    # The list from YAML is already an array of strings, so you can just render it.
    # Sorting is good practice.
    render json: cities.sort
  end

  # Redirect by profile URL
  def redirect_by_profile_url
    profile = PsychologistProfile.find_by(profile_url: params[:profile_url])
    if profile
      redirect_to psychologist_profile_path(profile), status: :moved_permanently
    else
      render plain: 'Profile not found', status: :not_found
    end
  end

  def set
    session[:currency] = params[:currency]
    redirect_back fallback_location: root_path, allow_other_host: false, params: { country: params[:country] }
  end

  def check_profile_url
    url = params[:profile_url].to_s.downcase.strip
    taken = PsychologistProfile.where.not(id: current_user&.psychologist_profile&.id)
                              .where(profile_url: url)
                              .exists?
    render json: { taken: taken }
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_psychologist_profile
      @psychologist_profile = PsychologistProfile.find(params.expect(:id))
    end

  def get_countries_with_cities_data
    # Access the pre-loaded data from application config
    Rails.application.config.countries_and_cities
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
            :is_degree_boolean, :profile_img, :religion,
            :about_clients, :about_issues, :about_specialties, :primary_contact_method, :timezone,
            :status, :youtube_video_url, :profile_url, :featured_service_id, :contact_email, :hidden,
            issue_ids: [],         # <-- Add this
            client_type_ids: [],  # <-- And this
            specialty_ids: [] ,     # <-- And this,
            language_ids: [],
            educations_attributes: [:id, :degree, :institution, :field_of_study, :graduation_year, :certificate_url, :_destroy]
            
          )
        end


end
