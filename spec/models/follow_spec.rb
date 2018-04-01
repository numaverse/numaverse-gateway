require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:follow) { create(:follow) }

  it 'validates uniqueness' do
    account1 = create(:account)
    account2 = create(:account)
    follow = create(:follow, from_account: account1, to_account: account2)
    follow2 = build(:follow, from_account: account1, to_account: account2)
    expect(follow2).not_to be_valid
  end

  describe 'activity pub' do
    it 'can model an activitypub object' do
      expect(follow.activity_stream.data).to eql(ActivityPub::Follow.new(follow).data)
    end
  end

  describe 'posting on chain', :end_to_end do
    let(:follow) { create(:follow, from_account: make_eth_account) }
    it 'should post and fetch from the blockchain' do
      follow.batch
      post_batch_on_chain(follow.sender_account.fetch_batch)

      NumaChain::Sync.sync!

      follow.reload
      expect(follow.confirmed?).to eql(true)
      expect(follow.from_account.from_transactions.size).to eql(1)
      expect(follow.batches.size).to eql(1)
      expect(follow.batches.first.tx).to be_present
      expect(follow.batch_items.first).to be_confirmed
    end
  end

  it 'creates a federated version of the follow' do
    follow.batch
    federated_follow = follow.reload.federated_follow
    expect(federated_follow).to be_present
    expect(federated_follow.from_account).to eql(follow.from_account.federated_account)
    expect(federated_follow.to_account).to eql(follow.to_account.federated_account)
  end
end
