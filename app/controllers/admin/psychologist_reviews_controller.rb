class Admin::PsychologistReviewsController < Admin::BaseController
  before_action :set_psychologist, only: [:show, :update_status, :update_education]

  def index
    @psychologists = PsychologistProfile.includes(:educations).order(:created_at)

    # Build counts for each status
    @education_counts = {}
    @psychologists.each do |p|
      counts = p.educations.group(:verification_status).count
      # Ensure all statuses exist, default to 0
      @education_counts[p.id] = {
        unverified: counts["unverified"] || 0,
        pending_review: counts["pending_review"] || 0,
        verified: counts["verified"] || 0,
        rejected: counts["rejected"] || 0
      }
    end
  end

  def show
    @educations = @psychologist.educations
  end

  # Update profile status
  def update_status
    if @psychologist.update(profile_status_params)
      redirect_back fallback_location: admin_psychologist_review_path(@psychologist),
                    notice: "Profile status updated."
    else
      redirect_back fallback_location: admin_psychologist_review_path(@psychologist),
                    alert: "Failed to update profile."
    end
  end

  # Update a single education
  def update_education
    edu = @psychologist.educations.find(params[:education_id])

    if edu.update(education_params.merge(
      verified_by: current_user,
      verified_at: Time.current
    ))
      redirect_back fallback_location: admin_psychologist_review_path(@psychologist),
                    notice: "Education updated."
    else
      # log errors to see why it failed
      Rails.logger.debug "Education errors: #{edu.errors.full_messages}"
      redirect_back fallback_location: admin_psychologist_review_path(@psychologist),
                    alert: "Failed to update education."
    end
  end


  private

  def set_psychologist
    @psychologist = PsychologistProfile.find(params[:id])
  end

  def profile_status_params
    params.require(:psychologist_profile).permit(:status)
  end

  def education_params
    params.require(:education).permit(:verification_status, :verification_notes)
  end
end
