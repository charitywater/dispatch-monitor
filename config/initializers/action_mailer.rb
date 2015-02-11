class PrefixEmailSubject
  def self.delivering_email(mail)
    mail.subject = "[#{Rails.env}] " + mail.subject if !Rails.env.production?
  end
end

ActionMailer::Base.register_interceptor(PrefixEmailSubject)
