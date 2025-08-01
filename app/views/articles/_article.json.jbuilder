json.extract! article, :id, :psychologist_profile_id, :title, :body, :is_published, :published_at, :slug, :status, :moderated_by_admin_id, :moderation_reason, :moderated_at, :created_at, :updated_at
json.url article_url(article, format: :json)
