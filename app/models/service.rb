class Service < ApplicationRecord
  belongs_to :user
  enum :delivery_method, { in_person: 0, online: 1, phone: 2 }

end
