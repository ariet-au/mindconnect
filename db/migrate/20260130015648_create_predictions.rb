class CreatePredictions < ActiveRecord::Migration[8.0]
  def change
    create_table :predictions do |t|
      t.text :prompt
      t.jsonb :response
      t.string :top_label
      t.float :top_score
      t.string :model_version
      t.boolean :user_marked_correct
      t.string :user_correct_label
      t.datetime :feedback_at

      t.timestamps
    end
  end
end
