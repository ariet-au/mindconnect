class ApplicationMailer < ActionMailer::Base
  # Set a specific email address from your verified Mailgun domain
  default from: "noreply@mail.aksanaa.com" 
  layout "mailer"
end