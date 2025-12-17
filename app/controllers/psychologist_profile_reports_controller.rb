class PsychologistProfileReportsController < ApplicationController
  before_action :set_psychologist_profile

  def new
    @report = @psychologist_profile.psychologist_profile_reports.new
  end

  def create
    @report = @psychologist_profile.psychologist_profile_reports.new(report_params)
    @report.reporter_user = current_user if user_signed_in?
    @report.ip_address = request.remote_ip
    @report.user_agent = request.user_agent

    if @report.save
      redirect_to @psychologist_profile, notice: "Report submitted. Thank you."
    else
      flash.now[:alert] = @report.errors.full_messages.to_sentence
      render :new
    end
  end

  private

  def set_psychologist_profile
    @psychologist_profile = PsychologistProfile.find(params[:psychologist_profile_id])
  end

  def report_params
    params.require(:psychologist_profile_report)
          .permit(:reason, :message, :reporter_phone, :reporter_email)
  end
end
