json.extract! psychologist_profile, :id, :user_id, :bio, :specialties, :years_of_experience, :license_number, :location, :created_at, :updated_at
json.url psychologist_profile_url(psychologist_profile, format: :json)
