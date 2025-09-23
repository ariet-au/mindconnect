class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_service, only: [:show, :edit, :update, :destroy]
  before_action :authorize_service_owner!, only: [:edit, :update, :destroy]
  before_action :check_user_confirmation,  only: %i[ edit update destroy ]
  
  
  def authorize_service_owner!
    redirect_to root_path, alert: "Not authorized" unless @service.user == current_user
  end
  # GET /services or /services.json
  def index
    @psychologist_profile = PsychologistProfile.find(params[:psychologist_profile_id])

    if current_user == @psychologist_profile.user
      # Show all, but order: active first, then archived
      @services = @psychologist_profile.services.order(status: :asc, archived_at: :asc)
    else
      # Show only active
      @services = @psychologist_profile.services.active
    end
  end

  

  # GET /services/1 or /services/1.json
  def show
    @service = Service.find(params[:id])
    @psychologist_profile = @service.user.psychologist_profile
  end

  # GET /services/new
  def new
    @service = Service.new
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services or /services.json
  def create
    @service = Service.new(service_params)
    @service.user_id = current_user.id 

    respond_to do |format|
      if @service.save
        format.html { redirect_to psychologist_profile_services_path(@service.user.psychologist_profile), notice: "Service was successfully created." }
        format.json { render :show, status: :created, location: @service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1 or /services/1.json
  def update
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to psychologist_profile_services_path(@service.user.psychologist_profile), notice: "Service was successfully created." }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1 or /services/1.json
  def destroy
    @service.destroy!

    respond_to do |format|
      format.html { redirect_to psychologist_profile_services_path(@service.user.psychologist_profile), notice: "Service was successfully created." }
      format.json { head :no_content }
    end
  end


  def archive
    @service = current_user.services.find(params[:id])
    @service.archive!
    redirect_to services_path, notice: "Service archived."
  end

  def unarchive
    @service = current_user.services.find(params[:id])
    @service.unarchive!
    redirect_to services_path, notice: "Service restored."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # app/controllers/services_controller.rb


    def set_service
      @service = Service.find_by(id: params[:id])

      unless @service
        redirect_to services_path, alert: "Service not found or has been deleted."
      end
    end

    def check_user_confirmation
      if user_signed_in? && !current_user.confirmed?
        flash[:alert] = "Please confirm your email address to continue."
        sign_out current_user
        redirect_to new_user_session_path
      end
    end

    # Only allow a list of trusted parameters through.
    def service_params
      params.require(:service).permit(
        :user_id,
        :name,
        :description,
        :price,
        :currency,
        :duration_minutes,
        :delivery_method
      )
    end
end
