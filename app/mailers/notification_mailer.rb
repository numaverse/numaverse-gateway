class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.mention.subject
  #
  def mention(account, message)
    @account = account
    @message = message

    mail to: @account.email, subject: "You've been mentioned in a message on Numa"
  end

  def tip(tip)
    @tip = tip
    @to = tip.to_account
    @from = tip.from_account
  
    mail to: @to.email, subject: "You just got a tip on Numa!"
  end
end
