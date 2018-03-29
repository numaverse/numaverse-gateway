class SyncChainJob < ApplicationJob
  queue_as :default

  def perform
    NumaChain::Sync.sync!
    SyncChainJob.set(wait: 10.seconds).perform_later
  end
end
