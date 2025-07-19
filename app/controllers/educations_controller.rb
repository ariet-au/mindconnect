class EducationsController < ApplicationController
  before_action :set_education, only: [:edit, :update, :destroy]

  def new
    @psychologist_profile = current_user.psychologist_profile
    @education = @psychologist_profile.educations.build
  end

  def create
    @psychologist_profile = current_user.psychologist_profile
    @education = @psychologist_profile.educations.build(education_params)

    if @education.save
      redirect_to edit_psychologist_profile_path(@psychologist_profile), notice: "Education added."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @education.update(education_params)
      redirect_to edit_psychologist_profile_path(@education.psychologist_profile), notice: "Education updated."
    else
      render :edit
    end
  end

  def destroy
    @education.destroy
    redirect_to edit_psychologist_profile_path(@education.psychologist_profile), notice: "Education deleted."
  end

  private

  def set_education
    @education = Education.find(params[:id])
  end

  def education_params
    params.require(:education).permit(:degree, :institution, :field_of_study, :graduation_year, :certificate_url)
  end
end
