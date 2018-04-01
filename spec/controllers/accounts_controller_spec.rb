require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  let(:account) { create(:account) }
  context 'signed in' do
    before { sign_in_account(account) }

    describe 'PUT #update' do
      let(:attrs) do
        {
          username: Faker::Internet.user_name.gsub(".","_"),
          avatar_ipfs_hash: SecureRandom.hex(20)
        }
      end

      before do
        put :update, params: { id: account.id, account: attrs }
      end

      it 'updates the account' do
        account.reload
        expect(account.username).to eql(attrs[:username])
        expect(account.avatar_ipfs_hash).to eql(attrs[:avatar_ipfs_hash])
      end

      it 'doesnt allow updating other accounts' do
        other = create(:account)
        expect {
          put :update, params: { id: other.id }
        }.to raise_error(CanCan::AccessDenied)
      end
            
    end

    describe 'GET #edit' do
      it 'sets the account' do
        get :edit, params: { id: account.id }
        expect(response).to have_http_status(:success)
      end

      it 'doesnt allow editing other accounts' do
        expect {
          get :edit, params: { id: create(:account).id }
        }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe 'GET #show' do
    let(:find_account) { create(:account_with_data) }

    it 'fetches by username' do
      get :show, params: { id: find_account.username }
      expect(assigns(:account)).to eql(find_account)
    end

    it 'fetches by hash_address' do
      get :show, params: { id: find_account.hash_address }
      expect(assigns(:account)).to eql(find_account)
    end

    it 'fetches by id' do
      get :show, params: { id: find_account.id }
      expect(assigns(:account)).to eql(find_account)
    end
  end
end
