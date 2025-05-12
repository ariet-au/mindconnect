class Specialty < ApplicationRecord
    has_many :psychologist_specialties, dependent: :destroy
    has_many :psychologist_profiles, through: :psychologist_specialties
end
