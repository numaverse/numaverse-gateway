class FetchTransactionDataJob < ApplicationJob
  queue_as :default

  def perform(tx)
    data = tx.get_blockchain_info
    tx.from_data(data)
    tx.save!
    if tx.pending?
      FetchTransactionDataJob.set(wait: 1.minute).perform_later(tx)
    end
  end
end
