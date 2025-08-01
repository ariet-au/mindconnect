class QuestionOption < ApplicationRecord
  belongs_to :question
  validates :label, :score, presence: true

end
