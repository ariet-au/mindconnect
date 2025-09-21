require "telegram/bot"

TELEGRAM_BOT = Telegram::Bot::Client.new(
  Rails.application.credentials.dig(:telegram, :bot_token)
)