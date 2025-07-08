class InternalClientProfile < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :client_profile

  enum status: { active: 0, inactive: 1, closed: 2, on_hold: 3 } # Example statuses

end
