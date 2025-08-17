class CreateQuizScoringRules < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_scoring_rules do |t|
      t.references :quiz, null: false, foreign_key: true
      t.integer :min_score, null: false
      t.integer :max_score, null: false
      t.string :label, null: false

      t.timestamps
    end
  end
end
