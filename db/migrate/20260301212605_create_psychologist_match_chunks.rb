class CreatePsychologistMatchChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :psychologist_match_chunks do |t|
      t.references :psychologist_profile, null: false, foreign_key: true

      t.text :content, null: false

      # Optional lightweight grouping
      t.string :category

      # Optional structured issue reference
      t.references :issue, null: true, foreign_key: true

      # Embedding column (must match your model dimension)
      t.vector :embedding, limit: 768

      t.timestamps
    end

    add_index :psychologist_match_chunks,
              :embedding,
              using: :ivfflat,
              opclass: :vector_cosine_ops
  end
end