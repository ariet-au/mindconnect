class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :target, polymorphic: true, optional: true

  validates :action_type, presence: true
  validates :occurred_at, presence: true

  before_validation :set_default_occurred_at

  # Smart logging method
  # Pass current_user, controller request object, action_type, target, extra metadata
  def self.log(user: nil, request: nil, action_type:, target: nil, metadata: {})
    # Enrich metadata with session, IP, and device info if request is provided
    if request
      metadata = metadata.merge(
        session_id: request.session.id,
        ip_address: request.remote_ip,
        device_type: request.user_agent&.match(/Mobile|Android|iPhone/) ? "mobile" : "desktop",
        user_agent: request.user_agent
      )
    end

    create!(
      user: user,
      action_type: action_type,
      target: target,
      metadata: metadata,
      occurred_at: Time.current
    )
  end

  private

  def set_default_occurred_at
    self.occurred_at ||= Time.current
  end
end
