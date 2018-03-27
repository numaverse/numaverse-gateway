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

  describe '#post_on_chain!', :end_to_end do
    let(:follow) { create(:follow, from_account: make_eth_account) }
    it 'should post and fetch from the blockchain' do
      post_message_on_chain(follow)

      expect(follow.tx).to be_present
      expect(follow.ipfs_hash).not_to be_blank
      expect(follow.from_account.from_transactions.size).to eql(1)

      from_chain = Networker.message_created_events
      expect(from_chain.first.topics[1]).to eql(follow.from_account.hash_address)

      NumaChain::Sync.messages

      follow.reload
      expect(follow.foreign_id).to eql(0)
    end
  end
end
