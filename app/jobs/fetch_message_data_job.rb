class FetchMessageDataJob < ApplicationJob
  queue_as :default

  def perform(message)
    message.try(:update_tx_data)
  end
end
