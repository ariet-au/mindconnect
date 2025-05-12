class PsychologistClientType < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :client_type
end
