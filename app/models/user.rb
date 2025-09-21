class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  
  after_create :create_associated_profile
  has_one :psychologist_profile, dependent: :destroy
  has_one :client_profile, dependent: :destroy # Add this line
  has_many :quizzes, dependent: :destroy

  has_many :services, dependent: :destroy
  enum :role, { client: 0, psychologist: 1, admin: 2 }



  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,:confirmable, :trackable # Add this line

     
  def remember_me
    true
  end
 


  def ensure_telegram_code!
    update!(telegram_verification_code: SecureRandom.hex(4)) if telegram_verification_code.blank?
  end

  def telegram_connected?
    telegram_chat_id.present?
  end
  private



  def create_associated_profile
    if psychologist?
      # Create a psychologist profile if the user's role is 'psychologist'
      create_psychologist_profile!
    elsif client?
      # Create a client profile if the user's role is 'client'
      # Provide default values for mandatory fields (null: false)
      create_client_profile!(

        timezone: "Asia/Bishkek" # Default timezone (adjust or infer later)

      )
    end
  end
end
