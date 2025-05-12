class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :psychologist_profile, dependent: :destroy
  has_many :services, dependent: :destroy
  enum :role, { client: 0, psychologist: 1, admin: 2 }



  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


 after_create :create_profile_if_psychologist

  private

  def create_profile_if_psychologist
    return unless psychologist?

    create_psychologist_profile!
  end
end
