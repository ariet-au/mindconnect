json.extract! issue, :id, :name, :description, :category, :severity_level, :created_at, :updated_at
json.url issue_url(issue, format: :json)
