class Follow < ApplicationRecord
  include ActivityStreamable

  validates_uniqueness_of :to_account_id, scope: [:from_account_id]

  belongs_to :to_account, class_name: "Account", foreign_key: 'to_account_id'
  belongs_to :from_account, class_name: "Account", foreign_key: 'from_account_id'

  def activity_stream
    ActivityPub::Follow.new(self)
  end

  def sender_account
    from_account
  end
end
