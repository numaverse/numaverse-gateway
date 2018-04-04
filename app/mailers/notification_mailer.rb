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

  def favorite(favorite)
    @favorite = favorite
    @message = favorite.message
    @from = favorite.account
    @to = @message.account

    mail to: @to.email, subject: "@#{@from.username} just favorited your message on Numa!"
  end

  def reply(reply)
    @to = reply.reply_to.account
    @from = reply.account
    @reply = reply

    mail to: @to.email, subject: "@#{@from.username} just replied to your message on Numa!"
  end

  def repost(repost)
    @to = repost.repost.account
    @from = repost.account
    @repost = repost

    mail to: @to.email, subject: "@#{@from.username} just reposted your message on Numa!"
  end
end
