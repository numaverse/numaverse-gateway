require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  # let(:user) { create(:user) }
  # let(:account) { user.managed_account }
  let(:account) { create(:account) }
  let(:message) { create(:message, account: account)}

  context 'logged out' do
    describe 'edit' do
      it 'should block' do
        get :edit, params: { id: message.id }
        expect(response).to redirect_to('/auth/login')
      end
    end

    describe 'update' do
      it 'should block' do
        put :update, params: { id: message.id }
        expect(response).to redirect_to('/auth/login')
      end
    end

    describe 'create' do
      it 'should block' do
        post :create, params: { body: 'blocked' }
        expect(response).to redirect_to('/auth/login')
      end
    end

    describe 'show' do
      it 'should be visible' do
        get :show, params: { id: message.id }
        expect(response).to be_success
      end
    end

    describe 'destroy' do
      it 'should block' do
        delete :destroy, params: { id: message.id }
        expect(response).to redirect_to('/auth/login')
      end
    end

    describe 'repost' do
      it 'should block' do
        post :repost, params: { id: message.id }
        expect(response).to redirect_to('/auth/login')
      end
    end

    describe 'reply' do
      it 'should block' do
        post :reply, params: { id: message.id }
        expect(response).to redirect_to('/auth/login')
      end
    end
  end

  context 'as message owner' do
    # before(:each) { (user.confirm && sign_in(user) ) }
    before(:each) { sign_in_account(account) }

    describe 'edit' do
      it 'can view edit page' do
        get :edit, params: { id: message.id }
        expect(response).not_to redirect_to('/auth/login')
        expect(response).to be_success
      end
    end

    describe 'update' do
      it 'can update' do
        new_body = SecureRandom.hex
        put :update, params: { id: message.id, body: new_body, format: :json }
        expect(message.reload.body).to eql(new_body)
      end
    end

    describe 'create' do
      it 'can create' do
        post :create, params: { body: 'hello world', json_schema: :micro, format: :json }
        expect(response).to be_success
      end
    end

    describe 'destroy' do
      it 'should update and mark as hidden' do
        delete :destroy, params: { id: message.id, format: :json }
        message.reload
        expect(message.hidden_at).to be_present
      end
    end

    describe 'repost' do
      it 'should make a repost' do
        original = create(:message)
        post :repost, params: { id: original.id, body: 'its a repost', format: :json }
        original.reload
        expect(original.reposts.size).to eql(1)
        expect(original.repost_count).to eql(1)
        expect(original.reposts.first.body).to eql(original.body)
      end
    end

    describe 'reply' do
      it 'creates a reply' do
        original = create(:message)
        post :reply, params: { id: original.id, body: 'its a reply', format: :json }
        original.reload
        expect(original.replies.size).to eql(1)
        expect(original.reply_count).to eql(1)
        expect(original.replies.first.body).to eql('its a reply')
      end
    end

    describe 'tip' do
      let(:account) { account_with_balance }
      it 'makes a tip' do
        original = create(:message)
        tx = transfer_eth(account, original.account, 100)
        post :tip, params: { id: original.id, body: 'nice post', tx_hash: tx.hash_address, format: :json }
        expect(original.reload.tips.size).to eql(1)
        tip = original.tips.first
        expect(tip.message.body).to eql('nice post')
        expect(tip.message.account).to eql(account)
        expect(tip.value).to eql(tx.value)
        expect(tip.batch_items.batched.count).to eql(1)
        expect(tip.message.batch_items.batched.count).to eql(1)
      end
    end
  end

  context 'as non-owner' do
    let(:account) { create(:account) }
    before(:each) { sign_in_account(account) }
    let(:other) { create(:message) }

    describe 'edit' do
      it 'cant edit' do
        expect {
          get :edit, params: { id: other.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'update' do
      it 'cant update' do
        expect {
          post :update, params: { id: other.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    describe 'destroy' do
      it 'cant destroy' do
        expect {
          delete :destroy, params: { id: other.id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end

  end
end
