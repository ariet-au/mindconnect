class Admin::PsychologistReviewsController < ApplicationController
  before_action :set_psychologist, only: [:show, :update_all]

  def index
    @psychologists = PsychologistProfile.includes(:educations)

    @education_counts = {}

    @psychologists.each do |p|
      @education_counts[p.id] = {
        unverified:      p.educations.unverified.count,
        pending_review:  p.educations.pending_review.count,
        verified:        p.educations.verified.count,
        rejected:        p.educations.rejected.count
      }
    end
  end

  def show
  end

  def update_all
    if @psychologist.update(psychologist_params)
      redirect_to admin_psychologist_review_path(@psychologist),
                  notice: "Profile and education statuses updated successfully."
    else
      flash.now[:alert] = "Failed to update."
      render :show
    end
  end

  private

  def set_psychologist
    @psychologist = PsychologistProfile.find(params[:id])
  end

  def psychologist_params
    params.require(:psychologist_profile).permit(
      :status,
      educations_attributes: [
        :id,
        :verification_status,
        :verification_notes
      ]
    )
  end
end
