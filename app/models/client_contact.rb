class ClientContact < ApplicationRecord
  belongs_to :client_info

  CONTACT_METHODS = %w[whatsapp telegram phone email]

  validates :method, presence: true
  validates :value, presence: true
end