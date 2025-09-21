class TelegramNotifierJob < ApplicationJob
  queue_as :default

  def perform(chat_id, message)
    TELEGRAM_BOT.api.send_message(chat_id: chat_id, text: message)
  end
end
