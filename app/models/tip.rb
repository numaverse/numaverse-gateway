class Tip < ApplicationRecord
  include ActivityStreamable

  belongs_to :tx, class_name: 'Transaction'
  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'
  belongs_to :message, optional: true
  belongs_to :to_message, class_name: 'Message', optional: true

  def value
    tx.value
  end

  def value_cents
    tx.value_cents
  end

  def sender_account
    from_account
  end

  def activity_stream
    ActivityPub::Tip.new(self)
  end
end
