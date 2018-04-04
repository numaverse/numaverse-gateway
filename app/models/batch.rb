class Batch < ApplicationRecord
  include ActivityStreamable

  belongs_to :account
  has_many :batch_items

  def batchables
    batch_items.batched.order('batched_at asc').collect(&:batchable).compact
  end

  def activity_stream
    ActivityPub::Batch.new(self)
  end

  def after_confirmed
    batch_items.each(&:confirm!)
  end

  def after_pending
    batch_items.each(&:transact!)
  end

  def after_canceled
    update(ipfs_hash: nil)
    batch_items.each(&:cancel!)
  end
end
