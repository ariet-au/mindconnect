class TelegramsController < ApplicationController
  before_action :authenticate_user!, only: [:show, :regenerate_code]
  skip_before_action :verify_authenticity_token, only: [:webhook]
  

  def show
    current_user.ensure_telegram_code!
  end

  def regenerate_code
    current_user.update!(telegram_verification_code: SecureRandom.hex(4))
    redirect_to telegram_path, notice: "New Telegram code generated."
  end

  # API-only webhook
  def webhook
    begin
      update = JSON.parse(request.body.read)
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid JSON received: #{e.message}"
      return head :ok
    end

    chat_id = update.dig("message", "chat", "id")
    text = update.dig("message", "text")

    return head :ok if chat_id.nil? || text.nil?

    user = User.find_by(telegram_verification_code: text)

    if user
      user.update!(telegram_verified: true, telegram_chat_id: chat_id)
      send_message(chat_id, "✅ Verification successful!")
    else
      send_message(chat_id, "❌ Invalid verification code. Please try again.")
    end

    head :ok
  rescue => e
    Rails.logger.error "Webhook failed: #{e.message}\n#{e.backtrace.join("\n")}"
    head :internal_server_error
  end


  private

  # Sends a message back to the Telegram user
  def send_message(chat_id, text)
    token = ENV['TELEGRAM_BOT_TOKEN']
    return unless token

    url = "https://api.telegram.org/bot#{token}/sendMessage"
    HTTParty.post(url, body: { chat_id: chat_id, text: text })
  rescue => e
    Rails.logger.error "Failed to send Telegram message: #{e.message}"
  end
end
