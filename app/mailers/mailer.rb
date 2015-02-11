class Mailer < ActionMailer::Base
  default from: ENV['MAIL_DEFAULT_FROM'],
    to: ENV['MAIL_DEFAULT_TO']

  layout 'mailer'
end
