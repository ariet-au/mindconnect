class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :psychologist_profile, dependent: :destroy
  has_one :client_profile, dependent: :destroy # Add this line

  has_many :services, dependent: :destroy
  enum :role, { client: 0, psychologist: 1, admin: 2 }



  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,:confirmable # Add this line

     

 after_create :create_associated_profile

  private



  def create_associated_profile
    if psychologist?
      # Create a psychologist profile if the user's role is 'psychologist'
      create_psychologist_profile!
    elsif client?
      # Create a client profile if the user's role is 'client'
      # Provide default values for mandatory fields (null: false)
      create_client_profile!(
        name: "New Client User", # Provide a default name
        dob: Date.current - 25.years, # Example: default to 25 years ago
        gender: "Unspecified", # Default gender
        country: "Australia", # Default country (adjust based on your primary audience)
        city: "Unknown City", # Default city
        timezone: "Australia/Melbourne", # Default timezone (adjust or infer later)
        phone_number1: "N/A" # Default phone number
      )
    end
  end
end
