# app/controllers/therapy_plans_controller.rb
class TherapyPlansController < ApplicationController
  before_action :set_internal_client_profile
  before_action :set_therapy_plan, only: [:show, :edit, :update, :destroy] # Add this line

  def new
    @therapy_plan = @internal_client_profile.therapy_plans.new
  end

  def create
    @therapy_plan = @internal_client_profile.therapy_plans.new(therapy_plan_params)
    if @therapy_plan.save
      redirect_to [@internal_client_profile, @therapy_plan], notice: "Therapy plan created."
    else
      render :new
    end
  end

  def show
    # @therapy_plan is already set by set_therapy_plan before_action
  end

  def edit
    # @therapy_plan is already set by set_therapy_plan before_action
  end

  def update
    if @therapy_plan.update(therapy_plan_params)
      redirect_to [@internal_client_profile, @therapy_plan], notice: "Therapy plan updated successfully."
    else
      render :edit
    end
  end

def destroy
    @therapy_plan.destroy
    respond_to do |format|
      format.html { redirect_to internal_client_profile_path(@internal_client_profile), notice: "Therapy plan deleted." }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@therapy_plan) }
    end
  end

  private

  def set_internal_client_profile
    @internal_client_profile = InternalClientProfile.find(params[:internal_client_profile_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to internal_client_profiles_path, alert: "Client profile not found."
  end

  def set_therapy_plan
    @therapy_plan = @internal_client_profile.therapy_plans.find(params[:id])
  end

  def therapy_plan_params
    params.require(:therapy_plan).permit(:diagnosis, :short_term_goals, :long_term_goals, :intervention_details, :frequency, :duration_weeks, :start_date, :end_date, :progress_metrics)
  end
end