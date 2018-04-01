class Federated::Follow < ApplicationRecord
  belongs_to :from_account, foreign_key: 'from_account_id', class_name: 'Federated::Account'
  belongs_to :to_account, foreign_key: 'to_account_id', class_name: 'Federated::Account'
  belongs_to :local_follow, foreign_key: 'local_follow_id', class_name: 'Follow', optional: true

  after_create :deliver!

  scope :visible, -> { where('hidden_at is null') }

  def accept!
    return true unless from_account.remote? && to_account.local?

    json = ActivityPub::Accept.new(self).data
    # ap json

    request = ActivityPub::Request.new(from_account.inbox, 
      verb: :post,
      from_account: to_account,
      body: json,
    )
    response = request.perform
    Rails.logger.info("Response code #{response.code} from Accept request to #{from_account.inbox}")
  end

  def deliver!
    if to_account.remote?
      ActivityPub::DeliveryJob.perform_later(self)
    end
  end
end
