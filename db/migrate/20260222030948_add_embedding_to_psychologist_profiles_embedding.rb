class AddEmbeddingToPsychologistProfilesEmbedding < ActiveRecord::Migration[8.0]
  def change
    # Enable pgvector extension in this database
    enable_extension "vector" unless extension_enabled?("vector")

    # Add embedding column
    add_column :psychologist_profiles, :embedding, :vector, limit: 768

    # Index for fast similarity search
    add_index :psychologist_profiles,
              :embedding,
              using: :ivfflat,
              opclass: :vector_cosine_ops
  end
end