class ClientInfo < ApplicationRecord
  belongs_to :psychologist_profile
  has_many :client_contacts, dependent: :destroy

  accepts_nested_attributes_for :client_contacts, allow_destroy: true

  validates :first_name, :last_name, presence: true


  enum :submitted_by, { client: "client", psychologist: "psychologist" }

end
