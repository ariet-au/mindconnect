json.extract! client_profile, :id, :name, :dob, :gender, :country, :city, :address, :timezone, :phone_number1, :phone_number2, :telegram, :whatsapp, :user_id, :created_at, :updated_at
json.url client_profile_url(client_profile, format: :json)
