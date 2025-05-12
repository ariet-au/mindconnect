# app/models/psychologist_profile.rb

# This class defines the model for psychologist profiles.
# It belongs to a User and has an enumeration for gender.
class PsychologistProfile < ApplicationRecord
  belongs_to :user
  has_one_attached :profile_img

  #specialities 
  has_many :psychologist_specialties, dependent: :destroy
  has_many :specialties, through: :psychologist_specialties

  #client types
  has_many :psychologist_client_types, dependent: :destroy
  has_many :client_types, through: :psychologist_client_types
  
  #issues
  has_many :psychologist_issues, dependent: :destroy
  has_many :issues, through: :psychologist_issues

  enum :gender, {
    unspecified: 0, 
    male: 1,       
    female: 2,      
    other: 3      
  }

end