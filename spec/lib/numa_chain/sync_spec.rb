require 'rails_helper'

describe NumaChain::Sync, :end_to_end do
  describe 'users' do
    it 'adds random text to usernames that are already taken' do
      account = make_eth_account(username: 'hstove')
      account.batch
      batch = account.fetch_batch
      expect(batch.batch_items.batched.count).to eql(1)
      post_batch_on_chain(batch)
      expect(batch.batch_items.reload.pending.count).to eql(1)
      expect(batch.batch_items.batched.count).to eql(0)

      NumaChain::Sync.sync!

      expect(batch.batch_items.reload.pending.count).to eql(0)
      expect(batch.batch_items.confirmed.count).to eql(1)

      account2 = make_eth_account
      json = account2.ipfs_object_data
      expect_any_instance_of(Account).to receive(:ipfs_object_data).and_return(json.merge({preferredUsername: 'Hstove'}))
      account2.batch
      post_batch_on_chain(account2.fetch_batch)
      NumaChain::Sync.sync!

      account2.reload
      expect(account2.username).to start_with("hstove_")
    end

    it 'can interact with a users contract' do
      account = make_eth_account
      account.batch
      post_batch_on_chain(account.fetch_batch)

      NumaChain::Sync.sync!

      account.reload
      expect(account.confirmed?).to eql(true)
      old_batch = Batch.find_by(account_id: account.id)
      expect(old_batch).to be_confirmed

      account = make_eth_account
      account.batch
      batch = account.fetch_batch
      post_batch_on_chain(batch)
      address = account.hash_address
      json = account.ipfs_json
      account.destroy

      NumaChain::Sync.sync!

      account = Account.by_address(address)
      expect(account).to be_present
      expect(account.ipfs_json).to eql(json)

      account.update(
        display_name: "Another",
        avatar_ipfs_hash: "Qm" + SecureRandom.hex(22),
        username: "try_again",
        bio: "new bio"
      )
      account.add_to_batch
      post_batch_on_chain(account.fetch_batch)
      expect(account.from_transactions.size).to eql(2)
      json = account.ipfs_json

      NumaChain::Sync.sync!
      account.reload
      expect(account.ipfs_json).to eql(json)

    end
  end

  describe 'messages' do
    context 'microposts' do
      it 'fetches events from the blockchain' do
        account = make_eth_account
        message = create(:message, account: account)
        message.batch
        post_batch_on_chain(message.sender_account.fetch_batch)

        uuid = message.uuid
        message.destroy

        NumaChain::Sync.sync!

        message = Message.find_by(uuid: uuid)
        expect(message).to be_present
        expect(message.confirmed?).to eql(true)

        message = create(:message, account: make_eth_account)
        message.batch
        post_batch_on_chain(message.sender_account.fetch_batch)
        NumaChain::Sync.sync!
        expect(message.reload.confirmed?).to eql(true)
      end

      it 'works with updates' do
        account = make_eth_account
        message = create(:message, account: account)
        message.batch
        post_batch_on_chain(message.sender_account.fetch_batch)

        NumaChain::Sync.sync!

        message.reload
        expect(message.confirmed?).to eql(true)

        message.update(body: 'seconded', hidden_at: DateTime.now)
        message.batch
        post_batch_on_chain(message.sender_account.fetch_batch)

        message.update(body: 'this should get lost', hidden_at: nil)
        NumaChain::Sync.sync!

        message.reload
        expect(message.body).to eql('seconded')
        expect(message.hidden_at).not_to be_nil
      end
    end

    context 'articles' do
      it 'works for articles' do
        account = make_eth_account
        message = create(:article, account: account)

        message.batch
        post_batch_on_chain(message.sender_account.fetch_batch)
        old_message = message
        message.destroy

        NumaChain::Sync.sync!

        message = Message.find_by(uuid: old_message.uuid)
        expect(message).to be_present
        expect(message.json_schema).to eql('article')
        expect(message.body).to eql(old_message.body)
        expect(message.tldr).to eql(old_message.tldr)
        expect(message.title).to eql(old_message.title)
      end

      it 'works with updates' do
        account = make_eth_account
        message = create(:article, account: account)
        message.batch
        post_batch_on_chain(message.sender_account.fetch_batch)

        NumaChain::Sync.sync!

        message.reload
        expect(message.confirmed?).to eql(true)

        message.update(body: 'seconded')
        message.batch
        post_batch_on_chain(message.sender_account.fetch_batch)

        message.update(body: 'this should get lost')
        NumaChain::Sync.sync!

        message.reload
        expect(message.body).to eql('seconded')
      end

    end
  end

  context 'follows' do
    let(:follow) { create(:follow, from_account: make_eth_account) }
    it 'creates and syncs follows' do
      follow.batch
      post_batch_on_chain(follow.sender_account.fetch_batch)

      NumaChain::Sync.sync!

      follow.reload
      expect(follow.confirmed?).to eql(true)

      follow = create(:follow, from_account: make_eth_account)
      follow.batch
      post_batch_on_chain(follow.sender_account.fetch_batch)
      old_follow = follow
      follow.destroy

      NumaChain::Sync.sync!

      follow = Follow.find_by(uuid: old_follow.uuid)
      expect(follow.from_account).to eql(old_follow.from_account)
      expect(follow.to_account).to eql(old_follow.to_account)
    end
  end

  context 'favorites' do
    let(:message) { create(:message, foreign_id: 10) }
    let(:favorite) { create(:favorite, message: message, account: make_eth_account) }

    it 'works with favorites' do
      favorite.batch
      post_batch_on_chain(favorite.sender_account.fetch_batch)

      NumaChain::Sync.sync!

      favorite.reload
      
      expect(favorite.confirmed?).to eql(true)
    end

    it 'finds messages by uuid' do
      favorite.batch
      post_batch_on_chain(favorite.sender_account.fetch_batch)

      old_favorite = favorite
      favorite.destroy

      NumaChain::Sync.sync!

      favorite = Favorite.find_by(uuid: old_favorite.uuid)
      expect(favorite.account).to eql(old_favorite.account)
      expect(favorite.message).to eql(message)
    end
  end

  context 'tips' do
    skip 'works with tips' do
      from = account_with_balance(balance: 10000)
      to = create(:account)
      tip = from.tip(to, 500)

      post_message_on_chain(tip)

      expect(tip.ipfs_hash).to be_present

      NumaChain::Sync.sync!

      tip.reload
      expect(tip.foreign_id).to eql(0)

      to = create(:account)
      tip = from.tip(to, 250)

      post_message_on_chain(tip)
      
      old_tip = tip
      tip.destroy

      NumaChain::Sync.sync!

      tip = Tip.find_by(ipfs_hash: old_tip.ipfs_hash)
      expect(tip).to be_present
      expect(tip.tx).to eql(old_tip.tx)
      expect(tip.from_account).to eql(from)
      expect(tip.to_account).to eql(to)
    end

    skip 'works with tips that point to a message' do
      from = account_with_balance(balance: 10000)
      to = create(:account)
      message = create(:message, account: to)
      tip = from.tip(to, 250, message)

      post_message_on_chain(tip)
      
      old_tip = tip
      tip.destroy

      NumaChain::Sync.sync!

      tip = Tip.find_by(ipfs_hash: old_tip.ipfs_hash)
      expect(tip).to be_present
      expect(tip.tx).to eql(old_tip.tx)
      expect(tip.from_account).to eql(from)
      expect(tip.to_account).to eql(to)
      expect(tip.to_message).to eql(message)
    end
  end

  it 'only fetches events that havent been logged before' do
    account = make_eth_account

    account.batch
    post_batch_on_chain(account.fetch_batch)
    expect(NumaChain::Sync).to receive(:process_account).once.and_call_original
    NumaChain::Sync.sync!

    account.reload
    expect(account).to be_confirmed
    account.update(username: 'anoda')

    account.batch
    post_batch_on_chain(account.fetch_batch.reload)

    expect(NumaChain::Sync).to receive(:process_account).once.and_call_original
    NumaChain::Sync.sync!

    expect(account.batch_items.size).to eql(2)
  end

end