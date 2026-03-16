class PsychologistMatchChunksController < ApplicationController
  before_action :set_profile
  before_action :set_chunk, only: [:edit, :update, :destroy]

  def index
    @chunks = @profile.psychologist_match_chunks.order(created_at: :desc)
  end

  def new
    @chunk = @profile.psychologist_match_chunks.new
  end

  def create
    @chunk = @profile.psychologist_match_chunks.new(chunk_params)
    if @chunk.save
      redirect_to psychologist_profile_chunks_path(@profile), notice: "Chunk created!"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @chunk.update(chunk_params)
      redirect_to psychologist_profile_chunks_path(@profile), notice: "Chunk updated!"
    else
      render :edit
    end
  end

  def destroy
    @chunk.destroy
    redirect_to psychologist_profile_chunks_path(@profile), notice: "Chunk deleted!"
  end

  private

  def set_profile
    @profile = PsychologistProfile.find(params[:psychologist_profile_id])
  end

  def set_chunk
    @chunk = @profile.psychologist_match_chunks.find(params[:id])
  end

  def chunk_params
    params.require(:psychologist_match_chunk).permit(:content, :category, :possible_issue_id)
  end
end