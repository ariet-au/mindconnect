class Issue < ApplicationRecord
  has_many :psychologist_issues, dependent: :destroy
  has_many :psychologist_profiles, through: :psychologist_issues
end
 