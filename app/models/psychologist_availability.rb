class PsychologistAvailability < ApplicationRecord
  belongs_to :psychologist_profile

  attribute :start_time_of_day, TimeOnlyType.new
  attribute :end_time_of_day, TimeOnlyType.new

  validates :start_time_of_day, presence: true
  validates :end_time_of_day, presence: true
  validates :day_of_week, presence: true, inclusion: 0..6
  validate :end_time_must_be_after_start_time
  
  private

  def end_time_must_be_after_start_time
    return unless start_time_of_day && end_time_of_day
    unless end_time_of_day > start_time_of_day
      errors.add(:end_time_of_day, "must be after the start time")
    end
  end
end
