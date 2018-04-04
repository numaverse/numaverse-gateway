class Favorite < ApplicationRecord
  include ActivityStreamable

  belongs_to :account
  belongs_to :message

  after_create :update_favorite_count
  after_create :send_notification

  def update_favorite_count
    message.update(favorites_count: message.favorites.reload.count)
  end

  def activity_stream
    ActivityPub::Favorite.new(self)
  end

  def sender_account
    account
  end

  def send_notification
    if message.account.email.present?
      NotificationMailer.favorite(self).deliver_later
    end
  end

end
