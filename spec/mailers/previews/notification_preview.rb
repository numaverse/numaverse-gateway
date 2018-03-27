# Preview all emails at http://localhost:3000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification/mention
  def mention
    user = User.last
    # message = Message.new(body: "Yo @#{user.username}")
    message = Message.last
    NotificationMailer.mention(user, message)
  end

end
