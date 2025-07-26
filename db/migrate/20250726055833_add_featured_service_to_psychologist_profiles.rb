class AddFeaturedServiceToPsychologistProfiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :psychologist_profiles, :featured_service, foreign_key: { to_table: :services }
  end
end
