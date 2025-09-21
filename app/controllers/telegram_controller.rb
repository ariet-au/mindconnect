class TelegramController < ApplicationController
  before_action :authenticate_user!, only: [:show, :regenerate_code]
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def show
    current_user.ensure_telegram_code!
  end

  def regenerate_code
    current_user.update!(telegram_verification_code: SecureRandom.hex(4))
    redirect_to telegram_path, notice: "New Telegram code generated."
  end

  # this stays API-only
  def webhook
    update = params.permit!.to_h

    chat_id = update.dig("message", "chat", "id")
    text    = update.dig("message", "text")

    if text.present?
      user = User.find_by(telegram_verification_code: text)

      if user
        user.update(telegram_chat_id: chat_id, telegram_verification_code: nil)
        TELEGRAM_BOT.api.send_message(chat_id: chat_id, text: "✅ Telegram connected! You’ll now get notifications.")
      else
        TELEGRAM_BOT.api.send_message(chat_id: chat_id, text: "❌ Invalid code. Please check your profile.")
      end
    end

    head :ok
  end
end
