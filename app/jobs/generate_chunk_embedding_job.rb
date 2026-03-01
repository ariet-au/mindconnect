class GenerateChunkEmbeddingJob < ApplicationJob
  queue_as :default

  def perform(chunk_id)
    chunk = PsychologistMatchChunk.find(chunk_id)
    chunk_embedding = EmbeddingService.generate_for_chunk(chunk)
    chunk.update!(embedding: chunk_embedding)
  end
end