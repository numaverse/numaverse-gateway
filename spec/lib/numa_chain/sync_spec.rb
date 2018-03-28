require 'rails_helper'

describe NumaChain::Sync, :end_to_end do
  describe 'users' do
    it 'adds random text to usernames that are already taken' do
      account = make_eth_account(username: 'hstove')
      post_account_on_chain(account)
      NumaChain::Sync.users

      account2 = make_eth_account
      json = account2.ipfs_json
      expect(account2).to receive(:ipfs_json).and_return(json.merge({preferredUsername: 'Hstove'}))
      post_account_on_chain(account2)
      NumaChain::Sync.users

      account2.reload
      expect(account2.username).to start_with("hstove_")
    end
  end

  describe 'messages' do
    context 'microposts' do
      it 'fetches events from the blockchain' do
        account = make_eth_account
        message = create(:message, account: account)
        post_message_on_chain(message)

        expect(Networker.message_created_events.size).to eql(1)

        ipfs_hash = message.ipfs_hash
        message.destroy

        NumaChain::Sync.messages

        expect(Networker.message_created_events.size).to eql(0)
        message = Message.find_by(ipfs_hash: ipfs_hash)
        expect(message).to be_present
        expect(message.foreign_id).to eql(0)

        message = create(:message, account: make_eth_account)
        post_message_on_chain(message)
        NumaChain::Sync.messages
        expect(message.reload.foreign_id).to eql(1)
      end

      it 'works with updates' do
        messages_contract = Contract.numa.eth_contract
        account = make_eth_account
        message = create(:message, account: account)
        post_message_on_chain(message)

        NumaChain::Sync.messages

        message.reload
        expect(message.foreign_id).to eql(0)

        message.update(body: 'seconded', hidden_at: DateTime.now)
        post_message_on_chain(message)

        expect(Networker.message_updated_events.size).to eql(1)

        message.update(body: 'this should get lost', hidden_at: nil)
        NumaChain::Sync.messages

        expect(Networker.message_updated_events.size).to eql(0)
        message.reload
        expect(message.body).to eql('seconded')
        expect(message.hidden_at).not_to be_nil
      end
    end

    context 'articles' do
      it 'works for articles' do
        messages_contract = Contract.numa.eth_contract
        account = make_eth_account
        message = create(:article, account: account)

        post_message_on_chain(message)
        old_message = message
        message.destroy

        NumaChain::Sync.messages

        message = Message.find_by(ipfs_hash: old_message.ipfs_hash)
        expect(message).to be_present
        expect(message.json_schema).to eql('article')
        expect(message.body).to eql(old_message.body)
        expect(message.tldr).to eql(old_message.tldr)
        expect(message.title).to eql(old_message.title)
      end

      it 'works with updates' do
        messages_contract = Contract.numa.eth_contract
        account = make_eth_account
        message = create(:article, account: account)
        post_message_on_chain(message)

        NumaChain::Sync.messages

        message.reload
        expect(message.foreign_id).to eql(0)

        message.update(body: 'seconded')
        post_message_on_chain(message)

        expect(Networker.message_updated_events.size).to eql(1)

        message.update(body: 'this should get lost')
        NumaChain::Sync.messages

        expect(Networker.message_updated_events.size).to eql(0)
        message.reload
        expect(message.body).to eql('seconded')
      end
    end

    context 'follows' do
      let(:follow) { create(:follow, from_account: make_eth_account) }
      it 'creates and syncs follows' do
        post_message_on_chain(follow)

        from_chain = Networker.message_created_events
        expect(from_chain.first.topics[1]).to eql(follow.from_account.hash_address)

        NumaChain::Sync.messages

        follow.reload
        expect(follow.foreign_id).to eql(0)

        follow = create(:follow, from_account: make_eth_account)
        post_message_on_chain(follow)
        old_follow = follow
        follow.destroy

        NumaChain::Sync.messages

        follow = Follow.find_by(ipfs_hash: old_follow.ipfs_hash)
        expect(follow.from_account).to eql(old_follow.from_account)
        expect(follow.to_account).to eql(old_follow.to_account)
      end
    end

    context 'favorites' do
      let(:message) { create(:message, foreign_id: 10) }
      let(:favorite) { create(:favorite, message: message, account: make_eth_account) }

      it 'works with favorites' do
        post_message_on_chain(favorite)

        from_chain = Networker.message_created_events
        expect(from_chain.first.topics[1]).to eql(favorite.account.hash_address)

        NumaChain::Sync.messages

        favorite.reload
        
        expect(favorite.foreign_id).to eql(0)
        expect(favorite.ipfs_hash).to be_present
      end

      it 'finds messages by uuid' do
        message.update(foreign_id: nil)
        post_message_on_chain(favorite)

        old_favorite = favorite
        favorite.destroy

        NumaChain::Sync.messages

        favorite = Favorite.find_by(ipfs_hash: old_favorite.ipfs_hash)
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

        from_chain = Networker.message_created_events
        expect(from_chain.first.topics[1]).to eql(tip.from_account.hash_address)

        NumaChain::Sync.messages

        tip.reload
        expect(tip.foreign_id).to eql(0)

        to = create(:account)
        tip = from.tip(to, 250)

        post_message_on_chain(tip)
        
        old_tip = tip
        tip.destroy

        NumaChain::Sync.messages

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

        NumaChain::Sync.messages

        tip = Tip.find_by(ipfs_hash: old_tip.ipfs_hash)
        expect(tip).to be_present
        expect(tip.tx).to eql(old_tip.tx)
        expect(tip.from_account).to eql(from)
        expect(tip.to_account).to eql(to)
        expect(tip.to_message).to eql(message)
      end
    end
  end
end