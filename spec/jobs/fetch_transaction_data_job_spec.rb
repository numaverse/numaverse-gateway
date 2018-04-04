require 'rails_helper'

RSpec.describe FetchTransactionDataJob, type: :job do
  it 'fetches info' do
    tx = Transaction.make_by_address('0x'+SecureRandom.hex(32))
    expect {
      FetchTransactionDataJob.perform_later(tx)
    }.to enqueue_job(FetchTransactionDataJob)
  end
end
