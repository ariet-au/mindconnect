class Question < ApplicationRecord
  belongs_to :quiz
  has_many :question_options, dependent: :destroy

  validates :text, :input_type, presence: true
  accepts_nested_attributes_for :question_options, allow_destroy: true

  enum :input_type, { likert: "likert", boolean: "boolean" }
end
