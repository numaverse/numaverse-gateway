class BatchItem < ApplicationRecord
  include AASM

  belongs_to :batch
  belongs_to :batchable, polymorphic: true

  aasm do
    state :batched, initial: true
    state :pending
    state :confirmed

    event :transact do
      transitions from: [:pending, :batched], to: :pending
    end

    event :confirm do
      transitions from: [:batched, :pending], to: :confirmed
    end

    event :cancel do
      transitions from: [:batched, :pending], to: :batched
    end
  end
end
