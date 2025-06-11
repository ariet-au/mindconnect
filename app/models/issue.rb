class Issue < ApplicationRecord
  has_many :psychologist_issues, dependent: :destroy
  has_many :psychologist_profiles, through: :psychologist_issues

  has_and_belongs_to_many :client_types
end
 