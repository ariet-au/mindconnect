class Admin::PsychologistProfileReportsController < Admin::BaseController
  def index
    @reports = PsychologistProfileReport
                 .pending
                 .includes(:psychologist_profile)
                 .order(created_at: :desc)
  end

  def update
    report = PsychologistProfileReport.find(params[:id])
    report.update!(status: params[:status])
    redirect_to admin_psychologist_profile_reports_path
  end
  
  def mark_reviewed
    update_status(:reviewed)
  end

  def dismiss
    update_status(:dismissed)
  end

  def take_action
    update_status(:action_taken)
  end

  private

  def update_status(new_status)
    report = PsychologistProfileReport.find(params[:id])
    report.update!(status: new_status)
    redirect_to admin_psychologist_profile_reports_path, notice: "Report updated."
  end
end
