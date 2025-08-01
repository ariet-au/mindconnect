class Quiz < ApplicationRecord
  belongs_to :user

  has_many :questions, dependent: :destroy
  validates :title, presence: true

  accepts_nested_attributes_for :questions, allow_destroy: true

end
