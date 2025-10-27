class ClientInfosController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :set_psychologist_profile, only: [:index, :new, :create]
  before_action :set_client_info, only: [:show, :edit, :update, :destroy]
  
  require 'net/http'
  require 'json'

  include LocationDetectable


  # GET /client_infos
  def index
    # Base scope for this psychologist with eager loading
    @client_infos = @psychologist_profile.client_infos.includes(:client_contacts).order(created_at: :desc)

    # Counts per status
    @status_counts = @psychologist_profile.client_infos.group(:status).count.transform_keys(&:to_sym)
    @status_counts[:all] = @client_infos.count

    # Filter by status if valid
    if params[:status].present? && ClientInfo.statuses.key?(params[:status])
      @client_infos = @client_infos.where(status: params[:status])
    end
  end


  # GET /client_infos/new
def new
  @client_info = ClientInfo.new
  @client_info.client_contacts.build

  if params[:psychologist_profile_id].present?
    @client_info.psychologist_profile_id = params[:psychologist_profile_id]
    @client_info.submitted_by = "client"
  elsif user_signed_in? && current_user.psychologist_profile
    @client_info.psychologist_profile = current_user.psychologist_profile
    @client_info.submitted_by = "psychologist"
  else
    @client_info.submitted_by = "client"
  end

  # Prefill city from IP
  unless @current_city
    ip = request.remote_ip
    begin
      res = Net::HTTP.get(URI("https://ipinfo.io/#{ip}/json"))
      geo = JSON.parse(res)
      @current_city = geo["city"] && geo["country"] ? "#{geo['city']}, #{geo['country']}" : nil
    rescue
      @current_city = nil
    end
  end

  # Load countries + cities for autocomplete
  @countries_with_cities = get_countries_with_cities_data
end



def create
  @client_info = ClientInfo.new(client_info_params)

  if user_signed_in? && current_user.psychologist? && current_user.psychologist_profile.id == params[:psychologist_profile_id].to_i
  # Any logged-in psychologist submitting the form is a psychologist
    @client_info.psychologist_profile = current_user.psychologist_profile
    @client_info.submitted_by = :psychologist
    @client_info.status = :referred
  elsif params[:psychologist_profile_id].present?
    # Client submitting via a psychologist's profile
    @client_info.psychologist_profile_id = params[:psychologist_profile_id]
    @client_info.submitted_by = :client
  else
    # Guest client submitting with no profile
    @client_info.submitted_by = :client
  end

  if @client_info.save
    ActivityLog.log(
      user: current_user,             # will be nil if guest
      request: request,
      action_type: "created_client_info",
      target: @client_info,
      metadata: {
        submitted_by: @client_info.submitted_by,
        psychologist_profile_id: @client_info.psychologist_profile_id
      }
    )
    redirect_to client_infos_path, notice: "Thank you! Your information has been submitted."
  else
    render :new, status: :unprocessable_entity
  end
end

  # GET /client_infos/:id/edit
  def edit
    unless editable_by_psychologist?(@client_info)
      redirect_to client_infos_path, alert: "You cannot edit client info submitted by the client."
    end
  end

  # PATCH/PUT /client_infos/:id
  def update
    if editable_by_psychologist?(@client_info)
      if @client_info.update(client_info_params)
        ActivityLog.log(
          user: current_user,
          request: request,
          action_type: "updated_client_info",
          target: @client_info,
          metadata: {
            submitted_by: @client_info.submitted_by,
            changes: @client_info.previous_changes.except(:updated_at)
          }
        )
        redirect_to client_infos_path, notice: "Client updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to client_infos_path, alert: "You cannot update a client submitted by the client."
    end
  end

  # Optional: show a client info page
  def show
    @client_info = ClientInfo.find(params[:id])
  end

  def destroy
  # 1. Find the client info record using the ID from the URL parameters
    @client_info = ClientInfo.find(params[:id])

    # 2. Check authorization using your custom method
    if editable_by_psychologist?(@client_info)
      # 3. Use the locale-scoped path for redirection
      if @client_info.destroy
        redirect_to client_infos_path(locale: I18n.locale), notice: t('client_infos.delete_success', default: "Client deleted successfully.")
      else
        # Handle case where destroy fails (e.g., due to model callbacks or database constraints)
        redirect_to client_infos_path(locale: I18n.locale), alert: t('client_infos.delete_failure', default: "Client could not be deleted.")
      end
    else
      # 3. Use the locale-scoped path for redirection
      redirect_to client_infos_path(locale: I18n.locale), alert: t('client_infos.delete_unauthorized', default: "You cannot delete this client.")
    end
  end

  private

  def get_countries_with_cities_data
    data = YAML.load_file(Rails.root.join("config/countries_cities.yml"))

    data.map do |country|
      {
        "name" => country["name"],
        "translated_name" => I18n.t("countries.#{country['name'].parameterize(separator: '_')}", default: country["name"]),
        "cities" => country["cities"].map do |city|
          {
            "name" => city,
            "translated_name" => I18n.t("cities.#{city.parameterize(separator: '_')}", default: city)
          }
        end
      }
    end
  end

  def set_psychologist_profile
    if user_signed_in?
      @psychologist_profile = current_user.psychologist_profile
    elsif params[:psychologist_profile_id].present?
      @psychologist_profile = PsychologistProfile.find(params[:psychologist_profile_id])
    else
      @psychologist_profile = nil
    end
  end

  def set_client_info
    @client_info = ClientInfo.find(params[:id])
  end

  def client_info_params
    params.require(:client_info).permit(
      :first_name, :last_name, :year_of_birth, :city, :timezone, :reason_for_therapy, :status, 
      client_contacts_attributes: [:id, :method, :value, :_destroy]
    )
  end

  # Only allow edit/update if submitted by this psychologist
  def editable_by_psychologist?(client_info)
    client_info.psychologist? && client_info.psychologist_profile == current_user.psychologist_profile
  end
end
