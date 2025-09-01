class ClientInfosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_psychologist_profile, only: [:index, :new, :create]
  before_action :set_client_info, only: [:show, :edit, :update, :destroy]

  # GET /client_infos
  def index
    # Only show clients belonging to this psychologist
    @client_infos = @psychologist_profile.client_infos.includes(:client_contacts)
  end

  # GET /client_infos/new
  def new
    @client_info = ClientInfo.new
    if current_user.psychologist_profile
      @client_info.psychologist_profile = current_user.psychologist_profile
      @client_info.submitted_by = "psychologist"
    else
      @client_info.submitted_by = "client"
    end
    @client_info.client_contacts.build
  end

  # POST /client_infos
  def create
    @client_info = ClientInfo.new(client_info_params)

    if current_user.psychologist_profile
      # Psychologist submitting the record
      @client_info.psychologist_profile = current_user.psychologist_profile
      @client_info.submitted_by = "psychologist"
    else
      # Client submitting the record
      @client_info.submitted_by = "client"
    end

    if @client_info.save
      redirect_to client_infos_path, notice: "Client added successfully."
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
    # Only show if psychologist owns it or client submitted
    unless @client_info.psychologist_profile == @psychologist_profile || @client_info.client?
      redirect_to client_infos_path, alert: "You do not have access to this client."
    end
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
    @psychologist_profile = current_user.psychologist_profile
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
