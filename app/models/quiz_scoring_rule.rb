class QuizScoringRule < ApplicationRecord
  belongs_to :quiz

  validates :min_score, :max_score, :label, presence: true

end
