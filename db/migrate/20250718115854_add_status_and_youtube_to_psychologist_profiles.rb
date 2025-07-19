class AddStatusAndYoutubeToPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :psychologist_profiles, :status, :string, default: "pending_review", null: false
    add_column :psychologist_profiles, :youtube_video_url, :string
    add_column :psychologist_profiles, :profile_url, :string

    add_index :psychologist_profiles, :profile_url, unique: true
  end
end
