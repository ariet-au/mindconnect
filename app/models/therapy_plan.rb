class TherapyPlan < ApplicationRecord
    belongs_to :internal_client_profile
    belongs_to :issue, optional: true
    belongs_to :speciality, optional: true

    has_many :progress_notes, -> { order(note_date: :desc) }, dependent: :destroy

    enum :status, {
        draft: "draft",
        active: "active",
        paused: "paused",
        completed: "completed",
        discontinued: "discontinued"
    }
end
