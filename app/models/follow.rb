class Follow < ApplicationRecord
  include ActivityStreamable

  validates_uniqueness_of :to_account_id, scope: [:from_account_id]

  belongs_to :to_account, class_name: "Account", foreign_key: 'to_account_id'
  belongs_to :from_account, class_name: "Account", foreign_key: 'from_account_id'
  has_one :federated_follow, class_name: "Federated::Follow", foreign_key: 'local_follow_id'

  def activity_stream
    ActivityPub::Follow.new(self)
  end

  def sender_account
    from_account
  end

  def update_federated_model
    fed_follow = federated_follow || Federated::Follow.new(local_follow: self)
    fed_follow.update(
      from_account: from_account.update_federated_model,
      to_account: to_account.update_federated_model,
    )
    fed_follow
  end
end
