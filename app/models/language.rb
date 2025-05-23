class Language < ApplicationRecord

    has_many :psychologist_languages
    has_many :psychologist_profiles, through: :psychologist_languages
end
