class Batch < ApplicationRecord
  include ActivityStreamable

  belongs_to :account
  has_many :batch_items

  def batchables
    batch_items.batched.order('batched_at asc').collect(&:batchable)
  end

  def activity_stream
    ActivityPub::Batch.new(self)
  end
end
