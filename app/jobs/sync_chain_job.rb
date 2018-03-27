class SyncChainJob < ApplicationJob
  queue_as :default

  def perform
    # NumaChain::Sync.all_blocks
    PaperTrail.whodunnit = 'sync'
    NumaChain::Sync.users
    NumaChain::Sync.messages
    SyncChainJob.set(wait: 10.seconds).perform_later
  end
end
