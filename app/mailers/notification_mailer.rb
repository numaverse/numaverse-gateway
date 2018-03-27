class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.mention.subject
  #
  def mention(user, message)
    @user = user
    @message = message

    mail to: @user.email, subject: "You've been mentioned in a message on Numa"
  end
end
