class CreateProgressNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :progress_notes do |t|
      t.references :therapy_plan, null: false, foreign_key: true
      t.references :booking, foreign_key: true

      t.text :notes
      t.text :homework_assigned
      t.integer :assessment_score
      t.date :note_date

      t.timestamps
    end
  end
end
