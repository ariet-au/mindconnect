class Article < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :moderated_by_admin, class_name: "User", optional: true
  
  has_rich_text :body
  
  enum :status, {
    active: 0,
    hidden: 1,
    banned: 2,
    draft: 3
  }

  has_one_attached :cover_image

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
