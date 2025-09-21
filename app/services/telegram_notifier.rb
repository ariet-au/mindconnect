class TelegramNotifier
  def self.send_message(chat_id, message)
    TELEGRAM_BOT.api.send_message(chat_id: chat_id, text: message)
  rescue => e
    Rails.logger.error "Telegram send failed: #{e.message}"
  end
end