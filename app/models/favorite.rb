class Favorite < ApplicationRecord
  include ActivityStreamable

  belongs_to :account
  belongs_to :message

  after_create :update_favorite_count

  def update_favorite_count
    message.update(favorites_count: message.favorites.reload.count)
  end

  def activity_stream
    ActivityPub::Favorite.new(self)
  end

  def sender_account
    account
  end

end
