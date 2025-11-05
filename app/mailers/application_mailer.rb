class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAIL_FROM'] # 'notifications@smartxchange.es'
  # layout 'mailer'
end
