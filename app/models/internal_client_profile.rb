class InternalClientProfile < ApplicationRecord
  belongs_to :psychologist_profile
  belongs_to :client_profile, optional: true
  has_many :therapy_plans, dependent: :destroy
  has_many :bookings




  enum :status, { active: 0, inactive: 1, closed: 2, on_hold: 3 } 

  def label
    "#{first_name} #{last_name}" # or however you want it displayed
  end
end
