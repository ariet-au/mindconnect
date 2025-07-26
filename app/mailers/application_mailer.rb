# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "noreply@#{Rails.application.credentials.mailgun.sending_domain || Rails.application.credentials.mailgun.domain}"
  layout "mailer"
end