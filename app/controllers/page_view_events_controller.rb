# app/controllers/page_view_events_controller.rb
class PageViewEventsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    # 1. Find or create the parent PageView
    page_view = find_or_create_page_view

    # 2. Handle the specific event type
    case params[:event_type]
    when "scroll"
      handle_scroll_event(page_view)
    when "click"
      handle_click_event(page_view)
    else
      # Fallback for generic events
      page_view.page_view_events.create!(
        event_type: params[:event_type],
        metadata: params[:metadata]
      )
    end

    head :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def find_or_create_page_view
    # 1. Find the record or create it
    page_view = PageView.find_or_create_by!(
      session_id: session.id.to_s,
      url: params[:url]
    ) do |pv|
      # This only runs on the VERY first hit of the session
      pv.user = current_user
      pv.ip_address = request.headers["X-Forwarded-For"]&.split(",")&.first || request.remote_ip
      pv.referrer   = request.referrer
      pv.user_agent = request.user_agent
      pv.viewed_at  = Time.current
    end

    # 2. ALWAYS ensure the visitor_id is set (even if the record was found)
    if page_view.visitor_id.blank?
      page_view.update_column(:visitor_id, current_visitor_id)
    end

    page_view
  end

  def handle_scroll_event(page_view)
    scroll_percent = params.dig(:metadata, :scroll_percent).to_i
    
    event = page_view.page_view_events.find_or_initialize_by(event_type: "scroll")
    
    # Update only if it's a new record or a deeper scroll
    if event.new_record? || scroll_percent > (event.metadata["scroll_percent"] || 0)
      event.metadata = params[:metadata]
      event.save!
    end
  end

  def handle_click_event(page_view)
    # We create a NEW record for every click
    page_view.page_view_events.create!(
      event_type: "click",
      metadata: params[:metadata] # e.g., { element_id: "buy-btn", text: "Add to Cart" }
    )
  end
end