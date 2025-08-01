class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.references :psychologist_profile, null: false, foreign_key: true
      t.string :title
      t.boolean :is_published
      t.datetime :published_at
      t.string :slug
      t.integer :status
      t.integer :moderated_by_admin_id
      t.string :moderation_reason
      t.datetime :moderated_at

      t.timestamps
    end
  end
end
