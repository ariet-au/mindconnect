json.extract! service, :id, :user_id, :name, :description, :price, :duration_minutes, :delivery_method, :created_at, :updated_at
json.url service_url(service, format: :json)
