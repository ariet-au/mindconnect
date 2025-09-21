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
    update = JSON.parse(request.body.read)
    chat_id = update.dig("message", "chat", "id")
    text = update.dig("message", "text")

    if chat_id.nil? || text.nil?
      return head :ok  # ignore invalid messages
    end

    user = User.find_by(telegram_verification_code: text)

    if user
      # Mark user as verified
      user.update!(telegram_verified: true, telegram_id: chat_id)
      send_message(chat_id, "✅ Verification successful!")
    else
      send_message(chat_id, "❌ Invalid verification code. Please try again.")
    end

    head :ok
  end

  private

  # Sends a message back to the Telegram user
  def send_message(chat_id, text)
    token = ENV['TELEGRAM_BOT_TOKEN']
    url = "https://api.telegram.org/bot#{token}/sendMessage"

    HTTParty.post(url, body: { chat_id: chat_id, text: text })
  end
end
