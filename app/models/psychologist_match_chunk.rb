class PsychologistMatchChunk < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :issue, optional: true
  
  after_commit :generate_embedding_if_needed, on: [:create, :update]

  private

  def generate_embedding_if_needed
    if saved_change_to_content?
      GenerateChunkEmbeddingJob.perform_later(id)
    end
  end
end