class PsychologistMatchChunksController < ApplicationController
  before_action :set_profile
  before_action :set_chunk, only: [:update, :destroy]

  def index
    @chunks = @profile.psychologist_match_chunks.order(created_at: :desc)
    @new_chunk = @profile.psychologist_match_chunks.new
  end

  def create
    @chunk = @profile.psychologist_match_chunks.new(chunk_params)
    if @chunk.save
      redirect_to psychologist_profile_psychologist_match_chunks_path(@profile), notice: "Chunk created!"
    else
      @chunks = @profile.psychologist_match_chunks.order(created_at: :desc)
      render :index
    end
  end

  def update
    if @chunk.update(chunk_params)
      redirect_to psychologist_profile_psychologist_match_chunks_path(@profile), notice: "Chunk updated!"
    else
      @chunks = @profile.psychologist_match_chunks.order(created_at: :desc)
      @new_chunk = @profile.psychologist_match_chunks.new
      render :index
    end
  end

  def destroy
    @chunk.destroy
    redirect_to psychologist_profile_psychologist_match_chunks_path(@profile), notice: "Chunk deleted!"
  end

  private

  def set_profile
    @profile = PsychologistProfile.find(params[:psychologist_profile_id])
  end

  def set_chunk
    @chunk = @profile.psychologist_match_chunks.find(params[:id])
  end

  def chunk_params
    params.require(:psychologist_match_chunk).permit(:content, :category, :issue_id)
  end
end