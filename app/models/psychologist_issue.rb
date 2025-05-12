class PsychologistIssue < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :issue
end
