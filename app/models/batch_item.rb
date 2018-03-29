class BatchItem < ApplicationRecord
  include AASM

  belongs_to :batch
  belongs_to :batchable, polymorphic: true

  aasm do
    state :batched, initial: true
    state :confirmed

    event :confirm do
      transitions from: :batched, to: :confirmed
    end
  end
end
