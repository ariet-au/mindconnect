# app/controllers/page_view_events_controller.rb
class PageViewEventsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    page_view = PageView.find_or_create_by!(
      session_id: session.id.to_s,
      url: params[:url],
      user: current_user,
      ip_address: request.headers["X-Forwarded-For"]&.split(",")&.first || request.remote_ip,
      referrer: request.referrer,
      user_agent: request.user_agent,
      viewed_at: Time.current
    )

    scroll_percent = params.dig(:metadata, :scroll_percent)&.to_i || 0

    # Only store if new max scroll for this page_view
    event = PageViewEvent.find_or_initialize_by(page_view: page_view, event_type: "scroll")
    if event.new_record? || scroll_percent > (event.metadata["scroll_percent"] || 0)
      event.metadata = params[:metadata]
      event.save!
    end

    head :ok
  end
end
