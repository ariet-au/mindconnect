class Quiz < ApplicationRecord
  belongs_to :user
  has_many :questions, dependent: :destroy
  has_many :quiz_scoring_rules, dependent: :destroy

  validates :title, presence: true
  accepts_nested_attributes_for :questions, allow_destroy: true

  def interpret_score(score)
    quiz_scoring_rules.find { |rule| score.between?(rule.min_score, rule.max_score) }&.label
  end
end