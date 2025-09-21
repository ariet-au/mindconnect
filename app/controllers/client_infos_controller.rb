class ClientInfosController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :set_psychologist_profile, only: [:index, :new, :create]
  before_action :set_client_info, only: [:show, :edit, :update, :destroy]
  

  # GET /client_infos
  def index
    # Only show clients belonging to this psychologist
    @client_infos = @psychologist_profile.client_infos.includes(:client_contacts).order(created_at: :desc)
  end

  # GET /client_infos/new
 def new
  @client_info = ClientInfo.new

  if params[:psychologist_profile_id].present?
    # Case 1: User clicked "Submit Client Info" from a psychologist's profile
    @client_info.psychologist_profile_id = params[:psychologist_profile_id]
    @client_info.submitted_by = "client"
  elsif user_signed_in? && current_user.psychologist_profile
    # Case 2: User clicked "Add New Client" and is a signed-in psychologist
    @client_info.psychologist_profile = current_user.psychologist_profile
    @client_info.submitted_by = "psychologist"
  else
    # Case 3: Guest user accessing the form without a psychologist profile
    @client_info.submitted_by = "client"
  end

  @client_info.client_contacts.build
end

def create
  @client_info = ClientInfo.new(client_info_params)

  if params[:psychologist_profile_id].present?
    # Case 1: User clicked "Submit Client Info" from a psychologist's profile
    @client_info.psychologist_profile_id = params[:psychologist_profile_id]
    @client_info.submitted_by = "client"
  elsif user_signed_in? && current_user.psychologist_profile
    # Case 2: User clicked "Add New Client" and is a signed-in psychologist
    @client_info.psychologist_profile = current_user.psychologist_profile
    @client_info.submitted_by = "psychologist"
  else
    # Case 3: Guest user submitting without a psychologist profile
    @client_info.submitted_by = "client"
    # psychologist_profile stays nil (unassigned)
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
    redirect_to root_path, notice: "Thank you! Your information has been submitted."
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
    if editable_by_psychologist?(@client_info)
      @client_info.destroy
      redirect_to client_infos_path, notice: "Client deleted successfully."
    else
      redirect_to client_infos_path, alert: "You cannot delete a client submitted by the client."
    end
  end

  private

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
      :first_name, :last_name, :year_of_birth, :city, :timezone, :reason_for_therapy,
      client_contacts_attributes: [:id, :method, :value, :_destroy]
    )
  end

  # Only allow edit/update if submitted by this psychologist
  def editable_by_psychologist?(client_info)
    client_info.psychologist? && client_info.psychologist_profile == current_user.psychologist_profile
  end
end
