# app/models/client_profile.rb
class ClientProfile < ApplicationRecord
  belongs_to :user

  # For the profile image
  has_one_attached :profile_img


  # Add validations for presence and format as needed

  def full_name
    "#{first_name} #{last_name}" # or however you want it displayed
  end
  # Example validation for profile image type/size (optional)
  # validates :profile_image, content_type: ['image/png', 'image/jpeg'],
  #                           max_size: 5.megabytes,
  #                           dimension: { width: 800, height: 800, resize_to_limit: [800, 800] }
end