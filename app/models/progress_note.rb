class ProgressNote < ApplicationRecord
    belongs_to :therapy_plan
    belongs_to :booking, optional: true
end
